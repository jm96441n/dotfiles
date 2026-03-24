---
description: execute scoped bd work within an optional scope
argument-hint: [scope-id]
allowed-tools: Bash(bd:*), Bash(jj *), Skill
---

# Execute BD Plan

## Overview

Execute BD work within an optional scope by repeatedly running `/bdexecissue` for the next ready issue.

The scope can be:

- an epic
- a story or other parent issue with child checkpoints
- a single leaf issue
- omitted, which means work through all ready issues in the repo

Each `/bdexecissue` runs in a forked context, so you see full progress while keeping the orchestrator context clean.

Use `jj` for all version control operations in this workflow. Do not use raw `git` commands for status, diff, commit, rebase, bookmark or branch management.

## Arguments

$ARGUMENTS

Optional scope ID. Use the ID that best matches the intended execution boundary.

- `epic`: execute all ready descendant work in that epic
- `story` or other parent issue: execute all ready descendant work in that scoped slice
- leaf issue: execute that single issue directly
- omitted: execute all ready work in the repo

## Instructions

### 1. Resolve the Scope

If a scope ID is provided, inspect it first:

```bash
bd show [scope-id] --json
bd dep tree [scope-id] --direction=down --type=parent-child --json
```

Use the result to classify the scope:

1. **Epic scope**: the issue type is `epic`
2. **Parent scope**: the issue is not an epic, but it has parent-child descendants
3. **Leaf scope**: the issue has no parent-child descendants

If the scope does not exist, stop immediately and report the error.

If the scope is a leaf issue, skip the orchestration loop and run `/bdexecissue [scope-id]` directly.

If the scope is an epic or other parent issue, use `bd ready --parent [scope-id] --json` for all ready-work queries.

### 2. Main Orchestration Loop

Repeat until no ready issues remain in the selected scope.

#### Step A: Find Ready Work

```bash
# If scoped to an epic or parent issue
bd ready --parent [scope-id] --json

# If unscoped
bd ready --json
```

Scoped execution should only consider ready descendant issues within the provided scope.

#### Step B: Select the Next Issue

- Choose the ready issue with the highest priority (lowest number)
- If tied, take the first one
- Do not overthink the selection

#### Step C: Show a Summary Card and Run `/bdexecissue`

Before invoking `/bdexecissue`, output a short summary card:

```text
----------------------------------------
STARTING: [issue-id] (P[priority])
  [issue title]
  [1-2 line summary]
----------------------------------------
```

Then invoke `/bdexecissue [issue-id]`.

#### Step D: Process the Result

When the issue completes, output a completion card:

```text
DONE: [issue-id] - [completed|blocked|needs-attention]
  [brief summary of what happened]
```

- If blocked, expect `/bdexecissue` to create or link blocker issues when needed
- Continue to the next ready issue in scope

#### Step E: Repeat

Re-run the same ready-work query and continue until it returns no ready issues.

### 3. Close a Completed Scope When Appropriate

When the ready-work query returns no issues, inspect whether the scoped work is actually complete or merely blocked.

If the run was scoped to an epic or other parent issue, query open descendants:

```bash
bd dep tree [scope-id] --direction=down --type=parent-child --status=open --json
```

Rules:

- If there are no remaining open child issues, close the scoped parent issue:

```bash
bd close [scope-id] --reason "All child issues completed" --json
```

- If open descendants still exist, leave the scope open and treat the run as incomplete or blocked.
- If the scope was a leaf issue, `/bdexecissue` is responsible for closing it.

### 4. Final Summary

Report:

- scope ID and scope title, if any
- issues attempted
- issues completed
- issues blocked or left open
- whether the scope itself was closed

## Example Session

```text
STARTING: proj-212 (P1)
  Checkpoint: implement auth middleware
  Add the core middleware path and wire protected routes

/bdexecissue proj-212

DONE: proj-212 - completed
  Middleware added, routes updated, tests passing

STARTING: proj-213 (P1)
  Checkpoint: add auth tests
  Verify the refreshed auth flow end to end

/bdexecissue proj-213

DONE: proj-213 - completed
  Added integration coverage and verified the story

bd dep tree proj-200 --direction=down --type=parent-child --status=open --json
-> no open descendants

bd close proj-200 --reason "All child issues completed" --json
```

## Best Practices

1. Keep the orchestrator lightweight and let `/bdexecissue` handle implementation details.
2. Use the narrowest meaningful scope so stories can execute and review independently.
3. Close parent scopes only when all child issues are complete.

## Stopping Conditions

Stop execution when:

- the scoped ready-work query returns no issues
- unscoped `bd ready --json` returns no issues
- a critical blocker requires human input
- repeated failures on the same issue indicate the run needs escalation
