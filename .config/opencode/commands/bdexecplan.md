---
description: execute scoped bd work within an optional scope
argument-hint: [scope-id]
allowed-tools: Bash(bd:*), Bash(jj *), Bash(git *), Task, Skill
model: github-copilot/claude-sonnet-4.6
---

# Execute BD Plan

## Overview

Execute BD work within an optional scope. For each ready issue in scope, this command runs the same workflow as `/bdexecissue` — but inline rather than by invoking the slash command, since slash commands cannot be fired by an agent.

The scope can be:

- an epic
- a story or other parent issue with child checkpoints
- a single leaf issue
- omitted, which means work through all ready issues in the repo

> **Important**: Do not try to invoke `/bdexecissue` directly — it is a user-facing slash command. Either execute each issue inline following the bdexecissue rules, or delegate execution to a `beads-task-agent` subagent via the `Task` tool to keep the orchestrator context clean.

This command is VCS-agnostic. Detect the repo's VCS once at the start (jj if `jj workspace root` succeeds, otherwise git if `git rev-parse --is-inside-work-tree` succeeds) and use it for all version control work in the executed issues.

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

If the scope is a leaf issue, skip the orchestration loop and execute that single issue directly using the inline bdexecissue workflow described in Step C.

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

#### Step C: Show a Summary Card and Execute the Issue

Before executing, output a short summary card:

```text
----------------------------------------
STARTING: [issue-id] (P[priority])
  [issue title]
  [1-2 line summary]
----------------------------------------
```

Then execute the issue. Pick one of:

**Option 1 — Inline (default)**: Run the bdexecissue workflow yourself in the current context:

1. `bd update [issue-id] --status in_progress`
2. `bd show [issue-id]` and read description / acceptance criteria
3. Implement the work using the detected VCS:
   - **jj**: `jj describe -m '...'`, `jj new`, make edits, `jj squash`
   - **git**: make edits, `git add <paths>`, `git commit -m '...'`
4. Run tests
5. `bd comment [issue-id] "Change <id-or-sha>: <what was done>"` after each meaningful unit
6. Verify acceptance criteria, then `bd close [issue-id] --reason "<summary>"`
7. If blocked: `bd create` a blocker, `bd dep add [issue-id] <blocker-id> --type blocks`, comment on the original, and `bd update [issue-id] --status open`

**Option 2 — Delegate via Task tool**: Spawn a subagent to keep the orchestrator context clean:

```text
Task(
  description="Execute issue [issue-id]",
  subagent_type="beads-task-agent",
  prompt="Execute bd issue [issue-id] following the bdexecissue workflow. Detect VCS (jj or git) and use it consistently. Mark in_progress immediately, implement with atomic commits, run tests, comment progress, close on completion (or create a blocker and reopen if blocked). Report final status: completed, blocked, or needs-attention."
)
```

#### Step D: Process the Result

When the issue completes, output a completion card:

```text
DONE: [issue-id] - [completed|blocked|needs-attention]
  [brief summary of what happened]
```

- If blocked, ensure blocker issues are created or linked, then move on
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
- If the scope was a leaf issue, the inline execution in Step C is responsible for closing it.

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

[execute inline: bd update proj-212 --status in_progress; jj describe / jj new / edits / jj squash; bd close]

DONE: proj-212 - completed
  Middleware added, routes updated, tests passing

STARTING: proj-213 (P1)
  Checkpoint: add auth tests
  Verify the refreshed auth flow end to end

[execute inline]

DONE: proj-213 - completed
  Added integration coverage and verified the story

bd dep tree proj-200 --direction=down --type=parent-child --status=open --json
-> no open descendants

bd close proj-200 --reason "All child issues completed" --json
```

## Best Practices

1. Keep the orchestrator focused on scoping and selection. Delegate or inline the per-issue execution work using the bdexecissue rules.
2. Use the narrowest meaningful scope so stories can execute and review independently.
3. Close parent scopes only when all child issues are complete.

## Stopping Conditions

Stop execution when:

- the scoped ready-work query returns no issues
- unscoped `bd ready --json` returns no issues
- a critical blocker requires human input
- repeated failures on the same issue indicate the run needs escalation
