---
description: execute-review-fix loop until review passes
argument-hint: [scope]
allowed-tools: Skill, Task, Bash(bd:*), Bash(jj *)
---
# BD Execute-Review-Fix Loop

## Overview
Self-correcting feedback loop: execute ready bd issues, review the resulting code, create fix issues from review findings, and re-execute until the review passes clean. Combines `/bdexecplan`, the `review` agent, and `/bdplan` into an automated quality loop.

## Arguments
$ARGUMENTS

Optional: epic ID or search term to scope which issues to work on. Passed through to `/bdexecplan` and used to filter `bd ready`.

## Loop Architecture
```
bdloop [scope]
  ├── Pre-loop: capture jj baseline, verify ready work exists
  │
  ├── Iteration N:
  │   ├── Record iteration baseline (jj log -r @ --no-graph -T 'change_id')
  │   ├── /bdexecplan [scope]
  │   ├── Check for changes since baseline (jj log)
  │   ├── Review iteration changes (review agent, scoped to diff)
  │   ├── Evaluate findings:
  │   │   ├── No Critical + No Recommendations → exit (success)
  │   │   └── Has Critical or Recommendations → /bdplan [findings]
  │   └── Verify new ready issues exist for next iteration
  │
  └── Final summary report
```

## Instructions

### 1. Pre-Loop Setup

#### Capture VCS Baseline
Record the current jj change ID before any work begins:
```bash
jj log -r @ --no-graph -T 'change_id ++ "\n"'
```
Store this as `LOOP_BASELINE` — used to scope the final summary.

#### Verify Ready Work Exists
```bash
bd ready
```
If scoped, filter to relevant issues. If nothing is ready, exit immediately with a message — there is nothing to do.

Initialize iteration counter to 0 and max iterations to **5**.

### 2. Iteration Loop

Repeat until a stopping condition is met:

#### Step A: Increment and Record Iteration Baseline
Increment the iteration counter. Record the current jj change ID:
```bash
jj log -r @ --no-graph -T 'change_id ++ "\n"'
```
Store as `ITER_BASELINE` for this iteration.

Output an iteration header:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⟳ ITERATION [N] of 5
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### Step B: Execute Plan
Invoke `/bdexecplan` with the scope argument:
```
Skill("bdexecplan", args="[scope]")
```
This runs all ready issues in the scope through `/bdexecissue`.

#### Step C: Check for Changes
After execution completes, check whether any new commits were produced:
```bash
jj log -r '$ITER_BASELINE::@ ~ $ITER_BASELINE' --no-graph
```
If no new changes exist since the iteration baseline, exit the loop — execution produced nothing to review.

#### Step D: Review Iteration Changes
Invoke the review agent scoped to only this iteration's changes:

```
Task(
  description="Review iteration [N] changes",
  subagent_type="review",
  prompt="Review the code changes made since jj change ID [ITER_BASELINE].

Use this command to see the diff:
  jj diff --from [ITER_BASELINE] --to @

Use this command to see the commit log:
  jj log -r '[ITER_BASELINE]::@'

Review all changed files thoroughly for correctness, security, best practices, error handling, and architecture."
)
```

#### Step E: Evaluate Review Findings
Parse the review agent's response. Count findings by category:
- **Critical** — must-fix issues (bugs, security, data integrity)
- **Recommendations** — should-fix improvements (performance, architecture, best practices)
- **Suggestions** — nice-to-have (informational only, do NOT trigger fixes)

**Stopping condition: exit the loop if zero Critical AND zero Recommendations.**

Output an evaluation card:
```
┌─ REVIEW RESULT (Iteration [N]) ──────
│ Critical:        [count]
│ Recommendations: [count]
│ Suggestions:     [count]
│ Verdict:         [PASS / NEEDS FIXES]
└───────────────────────────────────────
```

If PASS, exit the loop.

#### Step F: Create Fix Issues
If there are Critical or Recommendation findings, invoke `/bdplan` to create fix issues. Pass the review findings as the argument so bdplan can structure them into actionable issues:

```
Skill("bdplan", args="Fix issues from review iteration [N]:

[paste Critical and Recommendation findings here, not Suggestions]")
```

#### Step G: Verify New Ready Work
```bash
bd ready
```
If no new ready issues were created (bdplan produced nothing actionable, or all new issues are blocked), exit the loop — there is nothing more to execute.

**Oscillation check**: If the findings in this iteration are substantially similar to the previous iteration's findings, exit the loop with a warning — fixes are not converging. Compare finding descriptions; if >50% overlap, treat as oscillating.

#### Step H: Continue
Loop back to Step A for the next iteration.

### 3. Max Iteration Guard

If the iteration counter reaches 5, exit the loop regardless of review status. Output a warning:
```
⚠ MAX ITERATIONS (5) REACHED — exiting loop.
  Review still has findings. Manual attention needed.
```

### 4. Final Summary Report

After exiting the loop (for any reason), output a summary:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  BDLOOP COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Iterations:      [N]
  Issues executed:  [total count across all iterations]
  Exit reason:      [clean review / no changes / no new issues /
                     max iterations / oscillating fixes / no ready work]

  Iteration breakdown:
    1: Executed [X] issues, review found [Y] critical, [Z] recommendations
    2: Executed [X] issues, review found [Y] critical, [Z] recommendations
    ...

  Remaining suggestions (informational):
    - [any Suggestion-level findings from final review]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Stopping Conditions

Any of these triggers an exit:

| Condition | Exit Reason |
|-----------|-------------|
| Zero Critical + zero Recommendations in review | `clean review` |
| No new commits after `/bdexecplan` | `no changes` |
| No new ready issues after `/bdplan` | `no new issues` |
| Iteration counter reaches 5 | `max iterations` |
| Findings repeat across consecutive iterations | `oscillating fixes` |
| No ready work at start of loop | `no ready work` |
| Review agent fails/errors | `review error` (exit with warning) |

## Edge Cases

- **Review agent failure**: If the review Task errors or returns unusable output, exit the loop with a `review error` reason. Report what's known and recommend manual review.
- **Empty scope**: If `bd ready` returns nothing (or nothing matching scope) at any point, exit cleanly.
- **Oscillating fixes**: If two consecutive iterations produce >50% similar findings, exit with `oscillating fixes`. The fixes are not converging and human judgment is needed.
- **bdplan creates blocked issues**: If all new issues are blocked by existing open work, exit with `no new issues` since nothing can progress.

## Best Practices

1. **Stay lightweight** — orchestrator only tracks state, delegates all real work
2. **Trust the components** — `/bdexecplan` handles execution, review agent handles review, `/bdplan` handles planning
3. **Scope reviews narrowly** — only review each iteration's diff, not the entire codebase
4. **Report clearly** — keep the user informed with iteration cards and the final summary
5. **Exit early** — prefer stopping cleanly over grinding through marginal fixes
