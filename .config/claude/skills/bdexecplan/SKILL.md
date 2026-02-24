---
description: execute a set of bd issues sequentially
allowed-tools: Bash(bd:*), Skill
---
# Execute BD Plan

## Overview
Execute a bd plan by running /bdexecissue for each ready issue. Each issue runs in a forked context (context isolation without summarization), so you see full progress while keeping the orchestrator context clean.

## Arguments
$ARGUMENTS

Optional: epic ID or search term to scope which issues to work on. If not provided, works through all ready issues.

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

If an epic ID or scope is provided:
```bash
bd show [epic-id]          # Understand the plan
bd dep tree [epic-id]      # See structure
```

### 2. Main Orchestration Loop

Repeat until no ready issues remain:

#### Step A: Find Ready Work
```bash
bd ready
```

If scoped to an epic, filter to relevant issues.

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
bd ready
```
Loop back to Step B if issues remain.

### 3. Completion

When `bd ready` returns no issues:
```bash
bd list --status open    # Verify nothing remaining
```

If all issues in an epic are done:
```bash
bd close [epic-id] --reason "All subtasks completed"
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
bd ready
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
bd ready
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
bd ready
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

# Continue until bd ready returns empty...
```

## Best Practices

1. **Stay Lightweight** - Orchestrator only tracks status, doesn't do implementation
2. **Trust bdexecissue** - Let it handle the details
3. **React to Blockers** - Check if newly-ready issues include just-created blockers
4. **Report Progress** - Keep user informed of overall status between issues

## Stopping Conditions

Stop the loop when:
- `bd ready` returns no issues (success!)
- Critical blocker needs human input (report and ask)
- Repeated failures on same issue (escalate)
