---
description: execute a single bd issue
argument-hint: <issue key>
allowed-tools: Bash(bd *), Bash(tea *), Bash(jj *), Bash(ast-grep *), Bash(sg *), Read, Edit, Write, Glob, Grep
context: fork
---

# Execute Single BD Issue

## Overview

Execute a single bd issue with proper status tracking, commenting, and jj workflow integration. This command handles one issue in isolation, keeping context clean.

Execute the bd issue [issue-id] following the bdexecissue workflow:

1. IMMEDIATELY mark in_progress: bd update [issue-id] --status in_progress
2. Review details: bd show [issue-id]
3. Implement the work with atomic commits
4. Track progress with bd comments after commits
5. Verify acceptance criteria and tests pass
6. Close when complete: bd close [issue-id] --reason "[summary]"

If blocked, create blocker issues and report back.

Report final status: completed, blocked, or needs-attention.

## Arguments

$ARGUMENTS

The argument should be a bd issue ID (e.g., `proj-5`, `app-12`).

## Instructions

### 1. Claim the Issue Immediately

```bash
bd update [issue-id] --status in_progress
```

⚠️ **CRITICAL**: Do this FIRST before any other work.

### 2. Review Issue Details

```bash
bd show [issue-id]
```

Read the description, acceptance criteria, and any existing comments carefully.

### 3. Implement the Work

#### Commit Strategy

- **Commit early and often** - each logical unit of working code
- **Never commit broken code** (except failing tests before TDD implementation)
- **Clear messages** - explain why, not just what
- **No Claude references** in commit messages

#### Track Progress with Comments

After each meaningful commit:

```bash
bd comment [issue-id] "Commit [hash]: [what was done]"
```

### 4. Complete the Issue

#### Before Closing

- ✅ All acceptance criteria met
- ✅ Tests pass (run them!)
- ✅ All changes committed to jj
- ✅ No uncommitted files related to this issue

#### Close with Summary

```bash
bd close [issue-id] --reason "Brief summary of what was completed"
```

### 5. Report Back

When done, provide a brief summary:

- What was implemented
- Key commits made
- Any issues discovered (should be filed with `bd create`)
- Final status

## Handling Blockers

If you discover a blocker:

```bash
# Create blocker issue
bd create "Fix: [blocker description]" \
  --priority 0 \
  --description "Discovered while working on [issue-id]"

# Link dependency
bd dep add [issue-id] [blocker-id] --type blocks

# Comment on original
bd comment [issue-id] "Blocked by [blocker-id]: [reason]"

# Reopen original issue
bd update [issue-id] --status open
```

Then report back that the issue is blocked.

## Discovering New Work

If you find additional work needed:

```bash
bd create "[New task]" \
  --description "Discovered during [issue-id]: [context]"
bd comment [issue-id] "Created [new-id] for [reason]"
```

Continue with the original issue unless it's truly blocked.

## Error Handling

If you cannot complete the issue:

1. Document what was done in a comment
2. Document what's blocking completion
3. Either:
   - Create a blocker issue and link it
   - Or leave in_progress with clear comment about state
4. Report back with status and blockers

## Best Practices

1. **One Issue Focus** - Don't work on other issues, stay focused
2. **Atomic Commits** - Small, working increments
3. **Rich Comments** - Reference commits, document decisions
4. **Test Before Close** - Verify functionality works
5. **Clean Exit** - Always leave issue in a valid state (closed or clearly documented)
