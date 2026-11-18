/**
 * Engram — OpenCode plugin adapter
 *
 * Thin layer that connects OpenCode's event system to the Engram Go binary.
 * The Go binary runs as a local HTTP server and handles all persistence.
 *
 * Flow:
 *   OpenCode events → this plugin → HTTP calls → engram serve → SQLite
 *
 * Session resilience:
 *   Uses `ensureSession()` before any DB write. This means sessions are
 *   created on-demand — even if the plugin was loaded after the session
 *   started (restart, reconnect, etc.). The session ID comes from OpenCode's
 *   hooks (input.sessionID) rather than relying on a session.created event.
 */

import type { Plugin } from "@opencode/plugin"

// ─── Configuration ───────────────────────────────────────────────────────────

const ENGRAM_PORT = parseInt(process.env.ENGRAM_PORT ?? "7437")
const ENGRAM_URL = `http://127.0.0.1:${ENGRAM_PORT}`
const ENGRAM_BIN = process.env.ENGRAM_BIN ?? Bun.which("engram") ?? "/home/johnmaguire/.local/share/mise/installs/go/1.26.7/bin/engram"

// Engram's own MCP tools — don't count these as "tool calls" for session stats
const ENGRAM_TOOLS = new Set([
  "mem_search",
  "mem_save",
  "mem_update",
  "mem_delete",
  "mem_suggest_topic_key",
  "mem_save_prompt",
  "mem_session_summary",
  "mem_context",
  "mem_stats",
  "mem_timeline",
  "mem_get_observation",
  "mem_session_start",
  "mem_session_end",
])

// ─── Memory Instructions ─────────────────────────────────────────────────────
// These get injected into the agent's context so it knows to call mem_save.

const MEMORY_INSTRUCTIONS = `## Engram Persistent Memory — Protocol

You have access to Engram, a persistent memory system that survives across sessions and compactions.

### WHEN TO SAVE (mandatory — not optional)

Call \`mem_save\` IMMEDIATELY after any of these:
- Bug fix completed
- Architecture or design decision made
- Non-obvious discovery about the codebase
- Configuration change or environment setup
- Pattern established (naming, structure, convention)
- User preference or constraint learned

Format for \`mem_save\`:
- **title**: Verb + what — short, searchable (e.g. "Fixed N+1 query in UserList", "Chose Zustand over Redux")
- **type**: bugfix | decision | architecture | discovery | pattern | config | preference
- **scope**: \`project\` (default) | \`personal\`
- **topic_key** (optional, recommended for evolving decisions): stable key like \`architecture/auth-model\`
- **content**:
  **What**: One sentence — what was done
  **Why**: What motivated it (user request, bug, performance, etc.)
  **Where**: Files or paths affected
  **Learned**: Gotchas, edge cases, things that surprised you (omit if none)

Topic rules:
- Different topics must not overwrite each other (e.g. architecture vs bugfix)
- Reuse the same \`topic_key\` to update an evolving topic instead of creating new observations
- If unsure about the key, call \`mem_suggest_topic_key\` first and then reuse it
- Use \`mem_update\` when you have an exact observation ID to correct

### WHEN TO SEARCH MEMORY

When the user asks to recall something — any variation of "remember", "recall", "what did we do",
"how did we solve", or the equivalent in the user's language, or references to past work:
1. First call \`mem_context\` — checks recent session history (fast, cheap)
2. If not found, call \`mem_search\` with relevant keywords (FTS5 full-text search)
3. If you find a match, use \`mem_get_observation\` for full untruncated content

Also search memory PROACTIVELY when:
- Starting work on something that might have been done before
- The user mentions a topic you have no context on — check if past sessions covered it
- The user's FIRST message references the project, a feature, or a problem — call \`mem_search\` with keywords from their message to check for prior work before responding

### SESSION CLOSE PROTOCOL (mandatory)

Before ending a session or saying "done" / "that's it", you MUST:
1. Call \`mem_session_summary\` with this structure:

## Goal
[What we were working on this session]

## Instructions
[User preferences or constraints discovered — skip if none]

## Discoveries
- [Technical findings, gotchas, non-obvious learnings]

## Accomplished
- [Completed items with key details]

## Next Steps
- [What remains to be done — for the next session]

## Relevant Files
- path/to/file — [what it does or what changed]

This is NOT optional. If you skip this, the next session starts blind.

### AFTER COMPACTION

If you see a message about compaction or context reset, or if you see "FIRST ACTION REQUIRED" in your context:
1. IMMEDIATELY call \`mem_session_summary\` with the compacted summary content — this persists what was done before compaction
2. Then call \`mem_context\` to recover any additional context from previous sessions
3. Only THEN continue working

Do not skip step 1. Without it, everything done before compaction is lost from memory.
`

// ─── HTTP Client ─────────────────────────────────────────────────────────────

async function engramFetch(
  path: string,
  opts: { method?: string; body?: any } = {}
): Promise<any> {
  try {
    const res = await fetch(`${ENGRAM_URL}${path}`, {
      method: opts.method ?? "GET",
      headers: opts.body ? { "Content-Type": "application/json" } : undefined,
      body: opts.body ? JSON.stringify(opts.body) : undefined,
    })
    return await res.json()
  } catch {
    // Engram server not running — silently fail
    return null
  }
}

async function isEngramRunning(): Promise<boolean> {
  try {
    const res = await fetch(`${ENGRAM_URL}/health`, {
      signal: AbortSignal.timeout(500),
    })
    return res.ok
  } catch {
    return false
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

function extractProjectName(directory: string): string {
  // Try git remote origin URL
  try {
    const result = Bun.spawnSync(["git", "-C", directory, "remote", "get-url", "origin"])
    if (result.exitCode === 0) {
      const url = result.stdout?.toString().trim()
      if (url) {
        const name = url.replace(/\.git$/, "").split(/[/:]/).pop()
        if (name) return name
      }
    }
  } catch {}

  // Fallback: git root directory name (works in worktrees)
  try {
    const result = Bun.spawnSync(["git", "-C", directory, "rev-parse", "--show-toplevel"])
    if (result.exitCode === 0) {
      const root = result.stdout?.toString().trim()
      if (root) return root.split("/").pop() ?? "unknown"
    }
  } catch {}

  // Final fallback: cwd basename
  return directory.split("/").pop() ?? "unknown"
}

function truncate(str: string, max: number): string {
  if (!str) return ""
  return str.length > max ? str.slice(0, max) + "..." : str
}

/**
 * Strip <private>...</private> tags before sending to engram.
 * Double safety: the Go binary also strips, but we strip here too
 * so sensitive data never even hits the wire.
 */
function stripPrivateTags(str: string): string {
  if (!str) return ""
  return str.replace(/<private>[\s\S]*?<\/private>/gi, "[REDACTED]").trim()
}

// ─── Plugin Export ───────────────────────────────────────────────────────────

export default {
  id: "engram",
  async setup(ctx) {
    const directory = ctx.location.directory
    const oldProject = directory.split("/").pop() ?? "unknown"
    const project = extractProjectName(directory)

    // Track tool counts per session (in-memory only, not critical)
    const toolCounts = new Map<string, number>()

    // Track last nudge time per session to debounce save reminders
    const lastNudgeTime = new Map<string, number>() // sessionID -> epoch seconds

    // Track which sessions we've already ensured exist in engram
    const knownSessions = new Set<string>()

    // Sub-agent sessions must not be registered as top-level Engram sessions —
    // they cause session inflation (issue #116).
    const subAgentSessions = new Set<string>()

    async function ensureSession(sessionId: string): Promise<void> {
      if (!sessionId || knownSessions.has(sessionId)) return
      if (subAgentSessions.has(sessionId)) return
      knownSessions.add(sessionId)
      await engramFetch("/sessions", {
        method: "POST",
        body: { id: sessionId, project, directory },
      })
    }

    // Try to start engram server if not running
    if (!(await isEngramRunning())) {
      try {
        Bun.spawn([ENGRAM_BIN, "serve"], {
          stdout: "ignore",
          stderr: "ignore",
          stdin: "ignore",
        })
        await new Promise((r) => setTimeout(r, 500))
      } catch {
        // Binary not found or can't start — plugin will silently no-op
      }
    }

    // Migrate project name if it changed (one-time, idempotent).
    // Must run AFTER server startup to ensure the endpoint is available.
    if (oldProject !== project) {
      await engramFetch("/projects/migrate", {
        method: "POST",
        body: { old_project: oldProject, new_project: project },
      })
    }

    // Auto-import git-synced memories from .engram/manifest.json
    try {
      if (await Bun.file(`${directory}/.engram/manifest.json`).exists()) {
        Bun.spawn([ENGRAM_BIN, "sync", "--import"], {
          cwd: directory,
          stdout: "ignore",
          stderr: "ignore",
          stdin: "ignore",
        })
      }
    } catch {
      // Manifest doesn't exist or binary not found — silently skip
    }

    // ─── Event Listeners ───────────────────────────────────────────

    const controller = new AbortController()
    void (async () => {
      try {
        for await (const event of ctx.event.subscribe({ signal: controller.signal })) {
          const data = (event as any).data ?? {}
          const sessionId: string | undefined = data.sessionID
          if (!sessionId) continue

          if (event.type === "session.created") {
            const title: string = data.title ?? ""
            const isSubAgent = !!data.parentID || title.endsWith(" subagent)")
            if (isSubAgent) subAgentSessions.add(sessionId)
            else await ensureSession(sessionId)
          }

          if (event.type === "session.deleted") {
            toolCounts.delete(sessionId)
            knownSessions.delete(sessionId)
            subAgentSessions.delete(sessionId)
            lastNudgeTime.delete(sessionId)
          }
        }
      } catch {
        // stream aborted on unload
      }
    })()

    // ─── User Prompt Capture ──────────────────────────────────────

    await ctx.session.hook("prompt", async (event) => {
      const sessionId = event.sessionID
      if (subAgentSessions.has(sessionId)) return

      const content = (event.prompt.text ?? "").trim()
      // Only capture non-trivial prompts (>10 chars)
      if (content.length <= 10) return

      await ensureSession(sessionId)
      await engramFetch("/prompts", {
        method: "POST",
        body: {
          session_id: sessionId,
          content: stripPrivateTags(truncate(content, 2000)),
          project,
        },
      })
    })

    // ─── Tool Execution Hook ─────────────────────────────────────
    // Counts tool calls and passively captures subagent output.

    await ctx.tool.hook("execute.after", async (event) => {
      const tool = event.tool.toLowerCase()
      if (ENGRAM_TOOLS.has(tool) || [...ENGRAM_TOOLS].some((t) => tool.endsWith(`_${t}`))) return

      const sessionId = event.sessionID
      if (sessionId) {
        await ensureSession(sessionId)
        toolCounts.set(sessionId, (toolCounts.get(sessionId) ?? 0) + 1)
      }

      if ((tool === "subagent" || tool === "task") && event.status === "completed" && sessionId) {
        const text = JSON.stringify(event.result)
        if (text.length > 50) {
          await engramFetch("/observations/passive", {
            method: "POST",
            body: {
              session_id: sessionId,
              content: stripPrivateTags(text),
              project,
              source: "task-complete",
            },
          })
        }
      }
    })

    // ─── System Prompt: Always-on memory instructions ──────────
    // Appends to the last system part instead of adding a new one: some models
    // reject multiple system messages (GitHub issue #23).

    const appendSystem = (system: Array<{ type: string; text?: string }>, text: string) => {
      const last = system[system.length - 1]
      if (last && last.type === "text" && typeof last.text === "string") last.text += "\n\n" + text
      else system.push({ type: "text", text })
    }

    await ctx.session.hook("context", async (event) => {
      appendSystem(event.system as any, MEMORY_INSTRUCTIONS)

      // ── Save nudge ──────────────────────────────────────────────────────────
      // If it has been a long time since the last mem_save, append a reminder.
      // Any failure silently skips the nudge.
      try {
        const sessionID: string = event.sessionID ?? ""
        if (!sessionID || subAgentSessions.has(sessionID)) return

        // SQLite datetime('now') is UTC without a zone suffix; normalize first.
        const toEpochSecs = (ts: string): number => {
          if (!ts) return 0
          const normalized = ts.includes("T") ? ts : ts.replace(" ", "T") + "Z"
          const ms = new Date(normalized).getTime()
          return Number.isNaN(ms) ? 0 : Math.floor(ms / 1000)
        }

        const cooldownSecs = parseInt(process.env.ENGRAM_NUDGE_COOLDOWN_SECS ?? "900", 10)
        const nowSecs = Math.floor(Date.now() / 1000)

        const lastNudge = lastNudgeTime.get(sessionID)
        if (lastNudge !== undefined && nowSecs - lastNudge < cooldownSecs) return

        // Skip if the session is too young (< 5 minutes)
        let sessionStartEpoch = 0
        try {
          const sessionRes = await fetch(`${ENGRAM_URL}/sessions/${encodeURIComponent(sessionID)}`, {
            signal: AbortSignal.timeout(200),
          })
          if (sessionRes.ok) {
            const sessionData = await sessionRes.json()
            sessionStartEpoch = toEpochSecs(sessionData?.started_at ?? "")
          }
        } catch {
          return
        }
        if (sessionStartEpoch > 0 && nowSecs - sessionStartEpoch < 300) return

        let lastObsEpoch = 0
        try {
          const obsRes = await fetch(
            `${ENGRAM_URL}/observations?project=${encodeURIComponent(project)}&limit=1&sort=created_at:desc`,
            { signal: AbortSignal.timeout(200) }
          )
          if (obsRes.ok) {
            const obsData = await obsRes.json()
            lastObsEpoch = toEpochSecs(obsData?.[0]?.created_at ?? "")
          }
        } catch {
          return
        }

        if (lastObsEpoch === 0) return
        if (nowSecs - lastObsEpoch < 900) return

        appendSystem(
          event.system as any,
          "MEMORY REMINDER: It's been over 15 minutes since your last memory save. " +
            "If you've made decisions, discoveries, completed significant work, or found non-obvious things, " +
            "call mem_save now."
        )
        lastNudgeTime.set(sessionID, nowSecs)
      } catch {
        // never crash the hook
      }
    })

    // ─── Compaction Hook: Persist memory + inject context ──────────

    await ctx.session.hook("compaction", async (event) => {
      if (event.sessionID) await ensureSession(event.sessionID)

      const data = await engramFetch(`/context?project=${encodeURIComponent(project)}`)
      if (data?.context) appendSystem(event.system as any, data.context)

      appendSystem(
        event.system as any,
        `CRITICAL INSTRUCTION FOR COMPACTED SUMMARY:\n` +
          `The agent has access to Engram persistent memory via MCP tools.\n` +
          `You MUST include the following instruction at the TOP of the compacted summary:\n\n` +
          `"FIRST ACTION REQUIRED: Call mem_session_summary with the content of this compacted summary. ` +
          `Use project: '${project}'. This preserves what was accomplished before compaction. Do this BEFORE any other work."\n\n` +
          `This is NOT optional. Without this, everything done before compaction is lost from memory.`
      )
    })

    return () => controller.abort()
  },
} satisfies Plugin
