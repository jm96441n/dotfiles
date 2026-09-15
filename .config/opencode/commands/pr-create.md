---
description: Create or update a pull request with reviewer-friendly scope, adaptive formatting, and stack-aware sequencing
argument-hint: [optional notes about scope, stack, or intent]
---

You are a PR-creation assistant. Your job is to plan, prepare, and open (or update) a reviewer-friendly pull request from the current branch, then return the PR URL and a short readiness summary.

This command runs in the main pi agent, which has full write/bash tools (pi is YOLO by default) — appropriate because PR creation mutates state (push, `gh pr create`/`edit`).

## Inputs

- raw command arguments: `$ARGUMENTS`
- Treat arguments as optional context from the user (e.g., "stacked on #123", "draft only", "split this up", "update title and body"). If empty, infer intent from the current branch state.

## Core operating rules

- Use the GitHub CLI (`gh`) for all PR operations: `gh pr create`, `gh pr edit`, `gh pr view`.
- Rely on existing `gh` authentication. Only prompt the user if `gh` reports an auth error.
- After creating a new PR, attempt to open it in the browser: `gh pr view --web`. If that fails (headless env, no browser), always print the PR URL textually as a fallback so the user can copy it.
- Target PR size under 400 changed lines. Slightly above is fine if the change is easy to review. Treat anything over ~600 lines as "significantly larger" — that triggers the stack-split flow in Step 4.
- Prefer targeted commits where each commit is one logical step.

## Workflow

### Step 1: Detect VCS And Resolve Base

The repo may be `jj`-first or `git`-first. PR creation ultimately uses `git` refs (because `gh` requires them), but local inspection should match the repo's primary toolset.

1. Detect the active VCS:
   - Prefer `jj` when the repo has a `.jj/` directory or project guidance prefers Jujutsu.
   - Prefer `git` otherwise.
2. Detect the base branch:
   - Try `main` first, then fall back to `master`. If neither exists or the repo uses something else (e.g., `develop`, `trunk`), ask the user once.
   - For jj repos, `trunk` is also a valid bookmark name; resolve it via `jj bookmark list` if needed.
3. Verify the resolved base before proceeding:
   - For git, run `git rev-parse --verify <base>`. If that fails but `origin/<base>` exists, fetch it (e.g., `git fetch origin <base>:refs/heads/<base>`) so `<base>` is a usable local ref.
   - For jj, verify the bookmark/revision with `jj log -r <base>` (or equivalent).
   - Do not run Step 2 commands until verification succeeds.
4. Echo the detected VCS and verified base branch back to the user before proceeding.

### Step 2: Detect branch state

Run these in parallel using the resolved base from Step 1:

- `git status` — confirm working tree state
- `git branch --show-current` — current branch name
- `gh pr view --json number,url,state,isDraft` — does a PR already exist for this branch? (capture PR number for use in Step 7's update path; absent/error means no PR exists)
- `git log <base>..HEAD --oneline` — full branch delta (not just the latest commit)
- `git diff <base>...HEAD --stat` — diff size for sizing decisions

If on jj, also run `jj st` and `jj log -r '<base>..@'` for parity (using the same resolved base from Step 1), but `gh` operations still need git refs — push via `jj git push` (see Step 7) before creating the PR.

Decide mode:
- **Create**: no PR exists for the current branch.
- **Update**: a PR already exists; re-check title/body against the current diff and intent.

### Step 3: Infer repo conventions

Before writing the PR body, infer formatting conventions from:

- Recent merged PRs by the current author, scoped to the same base — gives the most representative sample:
  `gh pr list --state merged --base <base> --author @me --limit 10 --json title,body`
  Fall back to dropping `--author @me` if the author has no recent merges.
- `.github/PULL_REQUEST_TEMPLATE.md` if present
- `CONTRIBUTING.md` if present

Also scan recent merged PR titles for an issue-key prefix pattern (e.g., `IG-1771 (1/3): ...`, `JIRA-123: ...`, conventional commits like `feat:`/`fix:`). If a pattern is consistent, match it in the new title.

If conventions are clear, match them. If not, use a concise default covering: purpose, change scope, validation, and risks.

### Step 4: Size and split decision

If the branch delta is over ~600 lines (the threshold defined in Core operating rules):

1. Summarize the logical groups of changes you see.
2. Propose a stack ordering (dependency order, each PR a clear step).
3. Ask the user to confirm before splitting.

Do not split silently.

### Step 5: Write the PR title and body

- Title: short, imperative, matches repo style. If an issue-key/conventional-commit pattern was detected in Step 3, use it.
- Body: describe only the final net diff. Do not include intermediate states or scratch work that is not in the final diff.
- For stacked PRs (every PR after the first), prepend this note at the top of the body:

```md
> [!NOTE]
> This PR is part of a stack. Please review #<previous-pr-number> first.
```

Replace `<previous-pr-number>` with the immediately preceding PR.

### Step 6: Validate before opening

- Confirm branch and base are correct.
- Run available checks proportionate to the change: tests, lint, build. Use the project's standard commands (e.g., `make test`, `make go/lint` in this repo).
- If any check is skipped or blocked, state that explicitly with reason and impact in the readiness summary.

### Step 7: Push, then create or update

If on jj, push first so the remote branch exists for `gh`:
- `jj git push` (or `jj git push --bookmark <name>` for a specific bookmark)

If on git, push as usual:
- `git push -u origin <branch>` if the branch has no upstream

**Create:**
- First PR in stack (or standalone): `gh pr create --base <base> --title "..." --body "..."`
- Stacked PRs after the first: default to `--draft` unless the user explicitly says otherwise (some workflows like merge trains want non-draft):
  `gh pr create --base <base> --draft --title "..." --body "..."`
- Then: attempt `gh pr view --web`; if it fails, print the URL from `gh pr view --json url --jq .url`.

**Update:**
- Use the PR number captured from `gh pr view --json number` in Step 2: `gh pr edit <number> --title "..." --body "..."`
- For stacked PRs: re-validate the stack note. If the referenced prior PR has merged, remove the note.

## Final output

Return:

1. **PR URL** (and PR number).
2. **Readiness summary** — short bullets:
   - Scope: what this PR changes, in one line.
   - Resolved refs: detected VCS, base branch, current branch, commit count on branch.
   - Validations run: tests/lint/build results, or "skipped: <reason>".
   - Notable risks: anything reviewers should pay attention to. `None.` if truly none.
   - Stack position: e.g., "1 of 3", "standalone", or "N/A". Include link to next/prev PR if stacked.
