---
description: execute-review-fix loop until review passes
argument-hint: [scope-id]
allowed-tools: Skill, Task, Bash(bd:*), Bash(jj *), Bash(git *)
---

# BD Execute-Review-Fix Loop

## Overview

Run a self-correcting execution loop over a BD scope. The scope can be an epic, a story, another parent issue, a leaf issue, or omitted entirely. Each iteration delegates scoped execution to a `beads-task-agent` subagent (the same work that `/bdexecplan` would do interactively), reviews the resulting diff, then delegates fix-issue creation to a subagent (the same work `/bdplan` would do), and repeats until review passes cleanly or another stopping condition is met.

> **Important**: Do not try to invoke `/bdexecplan`, `/bdexecissue`, or `/bdplan` directly. Those are user-facing slash commands and cannot be fired by an agent. Always delegate via the `Task` tool as shown below.

Detect the repo's VCS at the start of the workflow and use it for all baselines, diffs, and change inspection:

- If `jj workspace root` succeeds, use **jj**. Track baselines as jj change IDs.
- Otherwise, if `git rev-parse --is-inside-work-tree` succeeds, use **git**. Track baselines as git commit SHAs.
- If neither is detected, stop and report that the repo has no recognized VCS.

Use the same VCS consistently for the entire loop. Do not mix jj and git commands.

## Arguments

$ARGUMENTS

Optional scope ID. Used for ready-work checks and passed through to the execution subagent.

## Loop Architecture

```text
bdloop [scope-id]
  |- Pre-loop: detect VCS, capture baseline, verify ready work exists
  |
  |- Iteration N:
  |  |- Record iteration baseline
  |  |- Task(beads-task-agent) — execute scoped plan
  |  |- Check for changes since baseline
  |  |- Task(review) — review iteration changes
  |  |- Evaluate findings
  |  |  |- No Critical + No Recommendations -> exit success
  |  |  `- Has Critical or Recommendations -> Task(general) — create fix issues
  |  `- Verify new ready work exists in scope
  |
  `- Final summary report
```

## Instructions

### 1. Pre-Loop Setup

#### Capture the VCS Baseline

Record the current change identifier before any work begins.

For jj:

```bash
jj log -r @ --no-graph -T 'change_id ++ "\n"'
```

For git:

```bash
git rev-parse HEAD
```

Store the result as `LOOP_BASELINE`.

Before starting the loop, inspect the working copy with `jj status` (jj) or `git status` (git). Throughout the loop, use the detected VCS for all inspection (`jj status` / `jj diff` / `jj log`, or `git status` / `git diff` / `git log`). Do not mix toolchains.

#### Verify Ready Work Exists

Use the scope-aware ready query:

```bash
# If scoped
bd ready --parent [scope-id] --json

# If unscoped
bd ready --json
```

If nothing is ready, exit immediately with `no ready work`.

Initialize iteration counter to `0` and max iterations to `5`.

### 2. Iteration Loop

#### Step A: Record the Iteration Baseline

Increment the iteration counter and record the current change identifier.

For jj:

```bash
jj log -r @ --no-graph -T 'change_id ++ "\n"'
```

For git:

```bash
git rev-parse HEAD
```

Store as `ITER_BASELINE`. Use the same identifier type (jj change ID or git commit SHA) consistently throughout the loop.

Output an iteration header:

```text
----------------------------------------
ITERATION [N] of 5
----------------------------------------
```

#### Step B: Execute the Scoped Plan

Delegate scoped execution to a subagent via the Task tool. **Do not** try to invoke the `/bdexecplan` slash command — slash commands can only be triggered by the user. Use the `beads-task-agent` subagent, which is designed for autonomous BD work:

```text
Task(
  description="Execute scope [scope-id]",
  subagent_type="beads-task-agent",
  prompt="Execute the bd scope [scope-id] following the bdexecplan workflow.

Repeat until no ready issues remain in scope:

1. Query ready work:
     bd ready --parent [scope-id] --json    (if scope provided)
     bd ready --json                        (if unscoped)

2. Pick the highest-priority ready issue (lowest number; ties broken by first).

3. Execute that single issue end-to-end following the bdexecissue workflow:
   - bd update <id> --status in_progress
   - bd show <id>
   - Detect VCS (jj or git) and use it consistently:
     * jj repos: jj describe -m '...'; jj new; make changes; jj squash
     * git repos: make changes; git add <paths>; git commit -m '...'
   - Run tests
   - bd comment <id> with progress notes referencing change IDs / commit SHAs
   - bd close <id> --reason '...'
   - If blocked: bd create blocker, bd dep add <id> <blocker> --type blocks,
     bd comment <id>, bd update <id> --status open

4. After all ready work in scope is complete, check open descendants:
     bd dep tree [scope-id] --direction=down --type=parent-child --status=open --json
   If none remain open, close the scope:
     bd close [scope-id] --reason 'All child issues completed' --json

Report which issues were attempted, completed, blocked, or left open, and whether the scope was closed."
)
```

If the scope is a single leaf issue, you can pass that issue ID directly with the same prompt — the subagent will detect that there's only one item to execute.

#### Step C: Check Whether Anything Changed

After execution completes, inspect whether new changes were produced.

For jj:

```bash
jj log -r '$ITER_BASELINE::@ ~ $ITER_BASELINE' --no-graph
```

For git:

```bash
git log --oneline "$ITER_BASELINE"..HEAD
git status --porcelain
```

If no new changes exist since the iteration baseline (no new commits and no uncommitted modifications), exit with `no changes`.

#### Step D: Review the Iteration Diff

Invoke the review agent scoped to this iteration only.

For jj:

```text
Task(
  description="Review iteration [N] changes",
  subagent_type="review",
  prompt="Review the code changes made since jj change ID [ITER_BASELINE].

Use these commands:
  jj diff --from [ITER_BASELINE] --to @
  jj log -r '[ITER_BASELINE]::@'

Review all changed files for correctness, security, error handling, maintainability, and architectural fit."
)
```

For git:

```text
Task(
  description="Review iteration [N] changes",
  subagent_type="review",
  prompt="Review the code changes made since git commit [ITER_BASELINE].

Use these commands:
  git diff [ITER_BASELINE]..HEAD
  git log [ITER_BASELINE]..HEAD

Review all changed files for correctness, security, error handling, maintainability, and architectural fit."
)
```

#### Step E: Evaluate Findings

Count findings by category:

- Critical
- Recommendations
- Suggestions

If Critical and Recommendations are both zero, exit with `clean review`.

Output an evaluation card:

```text
REVIEW RESULT (Iteration [N])
  Critical:        [count]
  Recommendations: [count]
  Suggestions:     [count]
  Verdict:         [PASS | NEEDS FIXES]
```

#### Step F: Create Fix Issues

If there are Critical or Recommendation findings, delegate fix-issue creation to a subagent via the Task tool. **Do not** try to invoke `/bdplan` — slash commands cannot be fired by an agent. Use the `general` subagent and inline the bdplan rules:

```text
Task(
  description="Plan fixes for iteration [N]",
  subagent_type="general",
  prompt="Create bd fix issues for the actionable findings below from review iteration [N]. Use the bdplan rules:

- Add new work beneath the most relevant existing scope when possible.
- Prefer new checkpoints within the active story (parent ID: [story-or-scope-id]) over creating new cross-cutting stories.
- Use bd create with --type task --labels checkpoint --parent <parent-id> --priority 1 (or 0 for Critical).
- Add blocking dependencies between fix checkpoints with --deps blocks:<id> when sequencing matters.
- Each issue description should include: Goal, Deliverable, Validation.

Findings to address (Critical and Recommendations only — ignore Suggestions):

[paste Critical and Recommendation findings here]

Report the new issue IDs created and which scope they were added under."
)
```

#### Step G: Verify New Ready Work Exists

Re-run the scope-aware ready query:

```bash
# If scoped
bd ready --parent [scope-id] --json

# If unscoped
bd ready --json
```

If no new ready work exists, exit with `no new issues`.

If the findings substantially repeat across consecutive iterations, exit with `oscillating fixes`.

#### Step H: Continue

Loop back to Step A.

### 3. Max Iteration Guard

If the iteration counter reaches `5`, exit with `max iterations` and report that manual attention is needed.

### 4. Final Summary Report

At the end, report:

- iterations run
- issues executed across all iterations
- exit reason
- per-iteration review counts
- remaining suggestion-level findings

## Stopping Conditions

Exit when any of these occurs:

- zero Critical and zero Recommendations in review
- no new changes after the execution subagent runs (no new jj revisions or no new git commits, and no uncommitted edits)
- no new ready issues after the fix-planning subagent runs
- iteration counter reaches 5
- findings repeat across consecutive iterations
- no ready work at start
- review task fails or returns unusable output

## Best Practices

1. Keep the loop lightweight and delegate real execution to the `beads-task-agent` subagent.
2. Use the narrowest scope that matches the work, especially story scope for reviewable slices.
3. Scope each review to the current iteration diff, not the entire codebase.
4. Let the fix-planning subagent create fix checkpoints or stories instead of embedding ad hoc todo lists.
5. Report clearly when the loop stopped because execution or review could not make progress.
