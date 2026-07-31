---
description: Flywheel Stage 2 — convert a polished markdown plan into bd issues with full dependency graph
argument-hint: <path-to-plan.md>
---

You orchestrate the Flywheel plan-to-beads conversion (https://agent-flywheel.com/complete-guide §4). The blog calls this a translation problem, not task extraction: every piece of context, reasoning, and intent in the plan must end up embedded in the beads themselves so a fresh agent can execute without reopening the plan.

The blog warns of the **plan-bead gap**: agents that polish the plan forever and never create the beads. Your job is to close that gap.

Note: the blog uses `br` (beads_rust). This repo uses `bd` (beads). All conversion uses `bd`.

## Inputs

- `$ARGUMENTS`: path to the polished plan markdown file. Required.

## Tools available

- `ask_question` — for user confirmation
- `pi -p` sub-agent spawned via bash — for the actual bead creation work (keeps raw `bd` JSON out of the orchestrator's context)
- `bash`, `read` — for validation

## Workflow

### Step 0: Validate inputs

1. If `$ARGUMENTS` is empty, ask via `ask_question`:
   - `header`: `"Plan file path"`
   - `question`: `"Path to the polished plan markdown file? (e.g., .opencode/plans/atlas-notes-plan-v5.md)"`
   - `options`: list any files in `.opencode/plans/` ending in `.md`, plus `Type a path`.
2. Verify the file exists with `bash` (`test -f <path> && wc -l <path>`).
3. If the plan is under 500 lines, warn the user via `ask_question`:
   - `header`: `"Plan looks short"`
   - `question`: `"This plan is only <N> lines. The blog notes Flywheel plans 'routinely reach 3,000–6,000+ lines' before bead conversion. Short plans tend to produce thin beads that lose context. Continue anyway?"`
   - `options`:
     - `Cancel — I'll run more refinement rounds first (Recommended)`
     - `Continue — I know what I'm doing`

### Step 1: Verify bd is initialized

Run `bash`: `bd stats --json 2>/dev/null || echo NOT_INITIALIZED`.

- If not initialized, ask via `ask_question`:
  - `header`: `"bd not initialized"`
  - `question`: `"This repo doesn't have a bd database yet. Initialize one before converting?"`
  - `options`:
    - `Initialize with default prefix 'bd' (Recommended)` — run `bd init` then proceed
    - `Cancel — I'll set up bd manually`

- If initialized, run `bd list --status=open --json | jq 'length'` to count existing open issues. If > 0, warn:
  - `header`: `"Existing open issues"`
  - `question`: `"There are <N> open bd issues already. The conversion will add many more. How should I proceed?"`
  - `options`:
    - `Add new beads alongside existing ones (Recommended)`
    - `Cancel — I want to clean up existing beads first`
    - `Show me the existing issues first` — if picked, run `bd list --status=open` and re-ask

### Step 2: Confirm conversion

Read the plan file. Show the user:
- File path and line count
- Top-level section headings (extract `^# ` and `^## ` lines)
- Estimated bead count: blog data points are 5,500-line plan → 347 beads, ~16 lines per bead. Show: `~<line_count / 16> beads expected`.

Call `ask_question`:
- `header`: `"Confirm conversion"`
- `question`: `"Ready to convert this plan into bd issues? This will create many issues with dependencies. The blog says: 'Once you're in bead space, you never look back at the markdown plan' — so we'll embed all context, rationale, and tests into the bead bodies."`
- `options`:
  - `Convert now (Recommended)`
  - `Cancel`

### Step 3: Delegate conversion to a pi sub-agent

Spawn a pi sub-agent via bash to do the bead creation work (this keeps raw `bd` JSON out of the orchestrator's context). Write the prompt below to a temp file, then run `pi -p --no-session @/tmp/beads-prompt.md`. The prompt is the verbatim Plan-to-Beads prompt from the blog (with `br` → `bd`):

> You are the beads-task-agent executing the Flywheel plan-to-beads conversion (agent-flywheel.com/complete-guide §4).
>
> **Plan file:** `<absolute path to plan>`
>
> **Verbatim conversion prompt (from the blog, `br` → `bd`):**
>
> OK so now read ALL of `<plan file path>`; please take ALL of that and elaborate on it more and then create a comprehensive and granular set of beads for all this with tasks, subtasks, and dependency structure overlaid, with detailed comments so that the whole thing is totally self-contained and self-documenting (including relevant background, reasoning/justification, considerations, etc.-- anything we'd want our "future self" to know about the goals and intentions and thought process and how it serves the over-arching goals of the project.) Use only the `bd` tool to create and modify the beads and add the dependencies. Use ultrathink.
>
> **Critical rules:**
>
> 1. **Self-contained beads:** every bead must be detailed enough that a fresh agent can execute it without reopening the plan. Embed background, rationale, design intent, test obligations, and acceptance criteria directly in the bead description.
> 2. **No pseudo-beads:** do NOT write beads as a markdown list and call it done. Each bead must be created via `bd create`. The blog explicitly warns about this failure mode.
> 3. **Rich content:** beads should be long. The description field accepts markdown. Embed code snippets, schema fragments, edge cases, failure modes.
> 4. **Complete coverage:** every concept from the plan must end up in at least one bead. Lose nothing.
> 5. **Explicit dependencies:** use `bd dep add <issue> <depends-on>` for every relationship. The dependency graph is what enables `bd ready` to compute the optimal execution order downstream.
> 6. **Include testing in beads:** comprehensive unit tests and e2e test scripts with detailed logging must be part of the bead obligations, not deferred to "we'll write tests later."
> 7. **Use parallel `pi -p` sub-agents for batch creation.** Creating 200–500 beads sequentially is slow — spawn additional `pi -p` processes for batches.
>
> **bd CLI reference (this repo's flavor):**
>
> ```
> bd create --title "..." --description "..." --type task|bug|feature|epic --priority 0-4
> bd label add <id> <label>          # add label after creation
> bd dep add <id> <depends-on-id>    # <id> depends on <depends-on-id>
> bd list --status=open --json
> bd show <id> --json
> bd update <id> --description "..." --notes "..." --status in_progress
> bd comments add <id> "..."
> bd stats --json
> ```
>
> Priority is numeric: 0=critical, 1=high, 2=medium, 3=low, 4=backlog.
>
> **Final output:** when done, run `bd stats --json` and `bd blocked --json` and report:
> - total beads created
> - count by type (task / feature / epic / bug)
> - count of dependency edges added
> - any orphan beads (no dependencies in either direction)
> - any cycles detected (these would be a bug — fix before returning)

Wait for the sub-agent's printed output.

### Step 4: Sanity check

Run a quick verification with `bash`:

```
bd stats --json
bd list --status=open --json | jq 'length'
bd blocked --json | jq 'length'
```

Check for red flags:
- If total open beads is < (plan_line_count / 30), the conversion was too thin. Warn the user.
- If there are zero blocked beads (i.e., zero dependency edges), the dependency graph is missing. Warn loudly.
- If there's exactly one bead, the agent failed. Tell the user to retry.

### Step 5: Final output

Print:

```
**Beads created.**

Plan: `<plan path>`
Total beads: <N>
Dependency edges: <count>
Ready to start (no blockers): <bd ready --json | jq length>

Next step: polish the beads before any implementation:

    /flywheel/polish

The blog calls this 'check your beads N times, implement once' — under-polished beads create improvisational swarms. Plan on 4–6+ polishing rounds.
```

## Failure modes

- **Agent writes pseudo-beads:** if the agent's response describes beads in markdown rather than running `bd create`, stop and rerun with stronger instructions. Detect by checking `bd stats` before and after — if no beads were actually created, the conversion failed.
- **Missing dependencies:** if `bd blocked` returns 0 issues, the dependency graph wasn't built. Re-spawn the pi sub-agent with: "the conversion completed but no `bd dep add` calls were made; go through every bead and add the dependency edges that the plan implies."
- **Over-eager bead creation in unrelated projects:** confirm `pwd` matches the project the plan is for. The user might have run this from the wrong directory.
