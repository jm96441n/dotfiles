---
name: session-close
description: Protocol for properly ending a coding session - ensures all work is committed, pushed, and handed off correctly.
license: MIT
compatibility: opencode
metadata:
  category: workflow
  tools: jj, bd
---

## When to use me

Use this skill when ending a work session. This ensures all work is properly saved, pushed, and documented for the next session.

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `jj git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   jj git fetch
   jj rebase -d main
   bd sync
   jj bookmark set <bookmark-name>
   jj git push -b <bookmark-name>
   jj status  # Verify push succeeded
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

## Critical Rules

- Work is NOT complete until `jj git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds

## Checklist

Before saying "done" or "complete", run this checklist:

```
[ ] 1. jj status                 (check what changed)
[ ] 2. jj describe -m "..."      (describe current commit)
[ ] 3. bd sync                   (sync beads changes)
[ ] 4. jj bookmark set <name>    (set bookmark on current commit)
[ ] 5. jj git push -b <name>     (push to remote)
```

**NEVER skip this.** Work is not done until pushed.
