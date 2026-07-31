---
name: jujutsu
description: Prefer Jujutsu (jj) over git for version control. Use squash workflow pattern where commits are described first, then changes are made in a scratch child commit and squashed into the parent.
license: MIT
compatibility: opencode
metadata:
  category: vcs
  tools: jj
---

## When to use me

Use this skill for all version control operations. Prefer `jj` commands over `git` unless:

- Jujutsu is not installed (`command -v jj` fails)
- Performing git-specific operations not yet supported (e.g., submodules)
- Working with CI systems that require raw git

## Mental model

Jujutsu differs fundamentally from git:

- **Working copy is always a commit**: No staging area. `@` represents your current working-copy commit.
- **Change IDs vs Commit IDs**: Change IDs (e.g., `kxryzmor`) are stable across rebases. Prefer them for references.
- **Bookmarks ≠ Branches**: Bookmarks don't auto-advance on commit. You must explicitly move them.
- **Anonymous commits are normal**: No branch/bookmark needed to start working.
- **History rewriting is first-class**: `squash`, `split`, `rebase` are core workflows.

## Preferred workflow: squash pattern

Separate intent (commit message) from implementation (working changes).

```bash
# 1. Create the described commit
jj new main -m "feat: implement user authentication"

# 2. Create a scratch child to work in
jj new

# 3. Make changes in the scratch commit

# 4. When satisfied, squash into the parent
jj squash

# 5. Repeat steps 2-4 for additional changes
```

### Multi-commit features

```bash
# First commit
jj new main -m "refactor: extract auth module"
jj new
# ... work ...
jj squash

# Second commit as child of first
jj new -m "feat: add JWT validation"
jj new
# ... work ...
jj squash
```

## Command reference

| Operation          | Command                    |
| ------------------ | -------------------------- |
| Status             | `jj status` or `jj st`     |
| Log                | `jj log`                   |
| Current diff       | `jj diff`                  |
| Show commit        | `jj show <change_id>`      |
| New commit         | `jj new`                   |
| Describe           | `jj describe -m "message"` |
| Squash into parent | `jj squash`                |
| Abandon            | `jj abandon`               |

## Git interop

| Operation     | Command                     |
| ------------- | --------------------------- |
| Fetch         | `jj git fetch`              |
| Push bookmark | `jj git push -b <bookmark>` |
| Push all      | `jj git push --all`         |

## Bookmark management

```bash
# Create/move bookmark to current commit
jj bookmark set feature-name

# Push to remote
jj git push -b feature-name

# After more work, must re-set bookmark before pushing again
jj bookmark set feature-name
jj git push -b feature-name
```

## Git command translations

| Git                       | Jujutsu                                                  |
| ------------------------- | -------------------------------------------------------- |
| `git status`              | `jj status`                                              |
| `git diff`                | `jj diff`                                                |
| `git commit -m "msg"`     | `jj commit -m "msg"` or `jj describe -m "msg" && jj new` |
| `git commit --amend`      | `jj describe` (message) or `jj squash` (content)         |
| `git checkout -b feature` | `jj new -m "feature"`                                    |
| `git rebase main`         | `jj rebase -d main`                                      |
| `git stash`               | `jj new` (old commit stays)                              |
| `git log --oneline`       | `jj log --no-graph`                                      |
| `git reflog`              | `jj op log`                                              |
| `git reset --hard`        | `jj abandon`                                             |

## Repository setup

Always use colocated repos for compatibility with git-expecting tools:

```bash
# New repo
jj git init --colocate

# Existing git repo
cd existing-repo
jj git init --colocate
```

## Common workflows

### Starting a feature

```bash
jj git fetch
jj new main -m "feat: add widget support"
jj new
# ... work ...
jj squash
jj bookmark set add-widget-support
jj git push -b add-widget-support
```

### Updating with upstream

```bash
jj git fetch
jj rebase -d main
```

### Code review fixes

```bash
jj edit <change_id>     # go to commit needing fixes
jj new                  # scratch commit
# ... make fixes ...
jj squash
jj bookmark set feature-name
jj git push -b feature-name
```

## Gotchas

1. **Bookmarks don't auto-advance**: After `jj git push`, run `jj bookmark set <name>` again before next push.

2. **Colocated sync**: Run `jj git export` if external tools aren't seeing changes, `jj git import` after raw git commands.

3. **Revset shortcuts**: `@` is current, `@-` is parent, `@--` is grandparent.

4. **Undo anything**: `jj undo` reverts last operation. `jj op log` shows history.

5. **Empty commits are fine**: Unlike git, empty commits are normal placeholders.

6. **Conflicts are commits**: Conflicts appear in the commit itself. Edit files to resolve, commit auto-updates.
