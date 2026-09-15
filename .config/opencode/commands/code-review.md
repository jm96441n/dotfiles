---
description: Code review orchestrator that delegates to specialized reviewers and synthesizes findings
argument-hint: [base-ref] [target-ref]
---

You are the router for the code review command. Resolve the review scope interactively, then delegate the entire review to the `review` agent.

## Inputs

- raw command arguments: `$ARGUMENTS`
- base ref: first positional argument; the branch or bookmark to compare against. Defaults to the repo's trunk bookmark/branch if not provided.
- target ref: second positional argument; the branch or bookmark containing the changes to review. Defaults to `@` (jj working copy) or `HEAD` (git) if not provided.

## Workflow

### Step 1: Resolve Refs And Confirm Scope

1. Parse `$ARGUMENTS` into `<base-ref>` and `<target-ref>` (in that order).
2. Detect the active VCS:
   - Prefer `jj` when the repo has a `.jj/` directory, project guidance prefers Jujutsu, or the author refers to change IDs/bookmarks.
   - Prefer `git` otherwise.
3. Apply defaults if an argument is missing:
   - jj: base ref defaults to `trunk` (fall back to `main`, then `master` if `trunk` does not exist); target ref defaults to `@`.
   - git: base ref defaults to `main` (fall back to `master` if `main` does not exist); target ref defaults to `HEAD`.
4. Verify both refs actually exist:
   - jj: `jj bookmark list` and/or `jj log -r <ref>`.
   - git: `git rev-parse --verify <ref>`.
5. If a ref cannot be resolved or the scope is ambiguous, ask the user once via `question` before proceeding.
6. Echo the resolved base ref, target ref, and detected VCS back to the user.

### Step 2: Delegate To The Review Agent

Spawn the `review` agent (read-only orchestrator with its own specialist reviewers) with the resolved scope:

```text
Task(
  description="Code review <base-ref>..<target-ref>",
  subagent_type="review",
  prompt="Run the code review workflow. Base ref: <base-ref>. Target ref: <target-ref>. VCS: <jj|git>."
)
```

Do not do the review work yourself — the agent analyzes the diff, delegates to `review-*` specialists, and synthesizes the unified report.

### Step 3: Relay The Report

Return the agent's final report to the user unchanged.
