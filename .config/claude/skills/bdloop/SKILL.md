---
description: execute-review-fix loop until review passes
argument-hint: [scope-id]
allowed-tools: Skill, Task, Bash(bd:*), Bash(jj *)
---

# BD Execute-Review-Fix Loop

## Overview

Run a self-correcting execution loop over a BD scope. The scope can be an epic, a story, another parent issue, a leaf issue, or omitted entirely. The loop executes work through `/bdexecplan`, reviews the resulting diff, creates fix issues with `/bdplan` when needed, and repeats until review passes cleanly or another stopping condition is met.

Use `jj` for all version control operations, baselines, diffs, and change inspection in this workflow. Do not use raw `git` commands or Git commit SHAs. Use jj change IDs throughout.

## Arguments

$ARGUMENTS

Optional scope ID. Passed directly through to `/bdexecplan` and used for ready-work checks.

## Loop Architecture

```text
bdloop [scope-id]
  |- Pre-loop: capture jj baseline, verify ready work exists
  |
  |- Iteration N:
  |  |- Record iteration baseline
  |  |- /bdexecplan [scope-id]
  |  |- Check for changes since baseline
  |  |- Review iteration changes
  |  |- Evaluate findings
  |  |  |- No Critical + No Recommendations -> exit success
  |  |  `- Has Critical or Recommendations -> /bdplan [findings]
  |  `- Verify new ready work exists in scope
  |
  `- Final summary report
```

## Instructions

### 1. Pre-Loop Setup

#### Capture the JJ Baseline

Record the current jj change ID before any work begins:

```bash
jj log -r @ --no-graph -T 'change_id ++ "\n"'
```

Store this as `LOOP_BASELINE`.

Before starting the loop, inspect the working copy with `jj status`. Throughout the loop, use `jj status`, `jj diff`, and `jj log` for all VCS inspection. Never substitute `git status`, `git diff`, or `git log`.

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

Increment the iteration counter and record the current change ID:

```bash
jj log -r @ --no-graph -T 'change_id ++ "\n"'
```

Store as `ITER_BASELINE`.

Use the jj change ID as the iteration marker. Do not switch to Git commit hashes at any point in the loop.

Output an iteration header:

```text
----------------------------------------
ITERATION [N] of 5
----------------------------------------
```

#### Step B: Execute the Scoped Plan

Invoke:

```text
Skill("bdexecplan", args="[scope-id]")
```

This runs the scope through `/bdexecissue` and scope-closing logic.

#### Step C: Check Whether Anything Changed

After execution completes, inspect whether new changes were produced:

```bash
jj log -r '$ITER_BASELINE::@ ~ $ITER_BASELINE' --no-graph
```

If no new changes exist since the iteration baseline, exit with `no changes`.

#### Step D: Review the Iteration Diff

Invoke the review agent scoped to this iteration only:

```text
Task(
  description="Review iteration [N] changes",
  subagent_type="review",
  prompt="Review the code changes made since jj change ID [ITER_BASELINE].

Use these commands:
  jj diff --from [ITER_BASELINE] --to @
  jj log -r '[ITER_BASELINE]::@'

Do not use raw git commands.

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

If there are Critical or Recommendation findings, invoke `/bdplan` with the actionable findings only:

```text
Skill("bdplan", args="Fix issues from review iteration [N]:

[paste Critical and Recommendation findings here]")
```

`/bdplan` should add the new work beneath the most relevant existing scope when possible. Prefer new checkpoints within the active story before creating cross-cutting follow-up stories.

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
- no new jj changes after `/bdexecplan`
- no new ready issues after `/bdplan`
- iteration counter reaches 5
- findings repeat across consecutive iterations
- no ready work at start
- review task fails or returns unusable output

## Best Practices

1. Keep the loop lightweight and delegate real execution to `/bdexecplan`.
2. Use the narrowest scope that matches the work, especially story scope for reviewable slices.
3. Scope each review to the current iteration diff, not the entire codebase.
4. Let `/bdplan` create fix checkpoints or stories instead of embedding ad hoc todo lists.
5. Report clearly when the loop stopped because execution or review could not make progress.
