---
description: execute a set of bd issues sequentially
argument-hint: [epic-id]
allowed-tools: Bash(bd:*), Skill
---
# Execute BD Plan

## Overview
Execute a bd plan by running /bdexecissue for each ready issue. Each issue runs in a forked context (context isolation without summarization), so you see full progress while keeping the orchestrator context clean.

## Arguments
$ARGUMENTS

Optional: beads epic ID to scope which issues to work on. If not provided, works through all ready issues.

## Instructions

### How it works
```
bdexecplan
    ├── /bdexecissue issue-1  (forked context, full output)
    ├── /bdexecissue issue-2  (forked context, full output)
    └── /bdexecissue issue-N  (forked context, full output)
```

Each `/bdexecissue` runs in a forked context—you see full progress, but tool calls don't pollute the main conversation.

### 1. Initial Plan Review (if scoped)

If an epic ID is provided:
```bash
bd show [epic-id] --json
bd dep tree [epic-id] --direction=down --type=parent-child --json
```

If the epic does not exist, stop immediately and report the error.

### 2. Main Orchestration Loop

Repeat until no ready issues remain:

#### Step A: Find Ready Work
```bash
# If epic scoped
bd ready --parent [epic-id] --json

# Otherwise
bd ready --json
```

If scoped to an epic, only consider the ready descendant issues returned by `bd ready --parent [epic-id] --json`.

#### Step B: Select Next Issue
- Choose by priority (lower number = higher priority)
- If tied, take the first one
- Don't deliberate - just pick and go

#### Step C: Show Summary Card, then Run /bdexecissue [issue-id]

Before invoking bdexecissue, output a brief summary card so the user knows what's being worked on:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ STARTING: [issue-id] (P[priority])
  [issue title]
  [1-2 line description or acceptance criteria summary]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Then use the Skill tool to invoke bdexecissue with the issue ID.

#### Step D: Process Result and Show Completion Card
When the issue completes, output a completion card:

```
✓ DONE: [issue-id] — [outcome: completed/blocked/needs-attention]
  [brief summary of what happened]
```

- If blocked, bdexecissue should have created/linked blocker issues
- Continue to next ready issue

#### Step E: Repeat
```bash
# If epic scoped
bd ready --parent [epic-id] --json

# Otherwise
bd ready --json
```
Loop back to Step B if issues remain.

### 3. Completion

When the ready-work query returns no issues:
```bash
# If epic scoped
bd dep tree [epic-id] --direction=down --type=parent-child --status=open --json

# Otherwise
bd list --status open --json
```

If an epic is scoped and the open parent-child tree shows no remaining open child issues, close the epic:
```bash
bd close [epic-id] --reason "All child issues completed" --json
```

## Orchestrator State Tracking

Keep a simple mental log:
- Issues attempted
- Issues completed
- Issues blocked (and why)
- New issues discovered

Report summary at end.

## Handling Blocked Issues

If an issue reports blocked:
1. Verify blocker issue was created
2. Check if blocker is something you can address
3. If blocker is ready, run /bdexecissue for it next
4. Otherwise, note it and continue with other ready work

## Example Session

```
# Start
bd ready --parent proj-100 --json
→ proj-12 (p1), proj-15 (p2), proj-18 (p2)

# Summary card before running
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ STARTING: proj-12 (P1)
  Add user authentication to API endpoints
  Implement JWT validation middleware for protected routes
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Run first issue
/bdexecissue proj-12
→ [forked context runs]

✓ DONE: proj-12 — completed
  Added JWT middleware, updated 3 endpoints, tests passing

# Check ready again
bd ready --parent proj-100 --json
→ proj-13 (p1, was blocked by proj-12), proj-15 (p2), proj-18 (p2)

# Summary card
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ STARTING: proj-13 (P1)
  Refactor database connection pooling
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/bdexecissue proj-13
→ [forked context runs]

✗ DONE: proj-13 — blocked
  Missing config schema, created proj-19 as blocker

# Check ready
bd ready --parent proj-100 --json
→ proj-19 (p0, blocker), proj-15 (p2), proj-18 (p2)

# Summary card for blocker
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
▶ STARTING: proj-19 (P0)
  Add config schema for connection pool settings
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/bdexecissue proj-19
→ [forked context runs]

✓ DONE: proj-19 — completed
  Added schema, proj-13 now unblocked

# Continue until bd ready --parent proj-100 --json returns empty...
```

## Best Practices

1. **Stay Lightweight** - Orchestrator only tracks status, doesn't do implementation
2. **Trust bdexecissue** - Let it handle the details
3. **React to Blockers** - Check if newly-ready issues include just-created blockers
4. **Report Progress** - Keep user informed of overall status between issues

## Stopping Conditions

Stop the loop when:
- `bd ready --parent [epic-id] --json` returns no issues for the scoped epic, or `bd ready --json` returns no issues when unscoped
- Critical blocker needs human input (report and ask)
- Repeated failures on same issue (escalate)
