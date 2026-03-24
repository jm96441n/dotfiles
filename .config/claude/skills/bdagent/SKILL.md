---
description: spawn agent worktree to execute bdloop
argument-hint: <branch-name> <scope-id>
allowed-tools: Bash(tmux-claude-worktree *), Bash(jj *), Bash(bd *)
---

# BD Agent Worktree

## Overview

Create a new jj worktree in a sibling directory, spawn a tmux session there, and start an agent running `/bdloop` on the specified scope. Use this after planning is complete when you want autonomous execution in an isolated workspace.

The scope may be:

- an epic
- a story
- another parent issue with child checkpoints
- a leaf issue

## Arguments

$ARGUMENTS

Required:

- `<branch-name>`: name for the new branch and worktree directory
- `<scope-id>`: BD scope to execute, such as an epic ID, story ID, or issue ID

Example:

```text
/bdagent feature-user-auth proj-100
/bdagent story-refresh-auth proj-123
```

## Workflow Context

This command is used after planning:

1. `/bdplan` creates or extends the epic, stories, and checkpoints
2. you choose the scope to execute
3. `/bdagent` creates an isolated worktree and starts `/bdloop [scope-id]`
4. the background agent executes, reviews, and fixes work for that scope

## Instructions

### 1. Validate Arguments

Verify both arguments are present:

```bash
if [[ -z "$branch_name" ]] || [[ -z "$scope_id" ]]; then
  echo "Error: Both branch-name and scope-id are required"
  echo "Usage: /bdagent <branch-name> <scope-id>"
  exit 1
fi
```

### 2. Verify the Scope Exists

Before creating the worktree, confirm the scope exists:

```bash
bd show "$scope_id"
```

If the scope does not exist, inform the user and suggest running `/bdplan` first.

### 3. Check Ready Work

Use the scope-aware ready query:

```bash
bd ready --parent "$scope_id" --json
```

If the scope is a leaf issue, `bd ready --parent` may be empty even though the issue itself is runnable. In that case, warn but proceed.

If no ready work exists for a parent scope, warn that the agent may immediately exit with `no ready work`.

### 4. Create the Worktree and Spawn the Agent

Run:

```bash
tmux-claude-worktree "$branch_name" "$scope_id"
```

The script should:

- create a jj worktree at `../$branch_name`
- create or switch to branch `$branch_name`
- create a tmux session named after the branch
- start an agent with `/bdloop $scope_id`
- leave the current session active

### 5. Report Success

Report:

```text
OK: agent worktree created and started

  Branch:        $branch_name
  Worktree:      ../$branch_name
  Scope:         $scope_id
  tmux session:  $session_name

The agent is now running /bdloop $scope_id in the background.

To monitor progress:
  tmux attach -t $session_name

To switch to the agent session:
  tmux switch-client -t $session_name
```

## Error Handling

- If `../$branch_name` already exists, suggest using a different branch name or cleaning up the old worktree.
- If the scope ID is invalid, exit before creating the worktree.
- If no ready work exists, warn but allow the user to proceed.
- If a tmux session with the same name already exists, suggest attaching to it or using a different branch name.

## Notes

- The current planning session stays active.
- The background agent will run `/bdloop`, which in turn uses `/bdexecplan` to execute and review the chosen scope.
- Multiple agents can run in parallel as long as they use different branches, worktrees, and scopes.
