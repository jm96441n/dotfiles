---
description: spawn agent worktree to execute bdloop
argument-hint: <branch-name> <epic-id>
allowed-tools: Bash(tmux-claude-worktree *), Bash(jj *), Bash(bd *)
---
# BD Agent Worktree

## Overview
Creates a new jj worktree in a sibling directory, spawns a tmux session there, and starts a Claude agent running `/bdloop` on the specified epic. Used after planning is complete to delegate execution to a separate agent in an isolated workspace.

## Arguments
$ARGUMENTS

**Required:**
- `<branch-name>`: Name for the new branch and worktree directory (e.g., "feature-auth", "fix-api-validation")
- `<epic-id>`: BD epic or issue ID to execute (e.g., "proj-100", "api-15")

**Example:**
```
/bdagent feature-user-auth proj-100
```

## Workflow Context

This skill is used **after** planning has been completed:

1. User and Claude complete planning session
2. Epic and tasks are created in beads with `/bdplan`
3. User invokes this skill to spawn a separate agent for execution
4. New agent runs `/bdloop` to execute-review-fix until passing
5. Original planning session remains available

## Instructions

### 1. Validate Arguments

Verify both arguments are provided:
```bash
# Arguments should be passed to skill, validate they exist
if [[ -z "$branch_name" ]] || [[ -z "$epic_id" ]]; then
  echo "Error: Both branch-name and epic-id are required"
  echo "Usage: /bdagent <branch-name> <epic-id>"
  exit 1
fi
```

### 2. Verify Epic Exists

Before creating the worktree, confirm the epic exists in beads:
```bash
bd show "$epic_id"
```

If the epic doesn't exist, inform the user and suggest running `/bdplan` first.

### 3. Check Ready Work

Verify there are ready issues for the epic:
```bash
bd ready --json | jq -r '.[] | select(.id | startswith("'"$epic_id"'")) | .id'
```

If no ready work exists, warn the user that the agent will have nothing to execute.

### 4. Create Worktree and Spawn Agent

Run the `tmux-claude-worktree` script:
```bash
tmux-claude-worktree "$branch_name" "$epic_id"
```

The script will:
- Create a jj worktree at `../$branch_name` (sibling directory)
- Create branch `$branch_name` and set it as working copy
- Create a new tmux session named after the branch
- Start Claude in that session with `/bdloop $epic_id`
- Leave the current session active (doesn't switch)

### 5. Report Success

Output a summary for the user:
```
✓ Agent worktree created and started

  Branch:      $branch_name
  Worktree:    ../$branch_name
  Epic:        $epic_id
  tmux session: $session_name

The agent is now running /bdloop $epic_id in the background.

To monitor progress:
  tmux attach -t $session_name

To switch to the agent session:
  tmux switch-client -t $session_name

Current session remains active for continued planning or monitoring.
```

## Error Handling

**Worktree directory exists:**
If `../$branch_name` already exists, the script will fail. Suggest using a different branch name or manually removing the old worktree.

**Epic doesn't exist:**
If the BD epic ID is invalid, inform the user and exit before creating the worktree.

**No ready work:**
Warn but proceed — the agent will report "no ready work" immediately and exit.

**tmux session exists:**
If a tmux session with the branch name already exists, the script will fail. Suggest attaching to the existing session or using a different branch name.

## Use Cases

**Post-planning delegation:**
```
User: "Okay, the plan looks good. Let's get started on proj-100."
/bdagent implement-auth proj-100
```

**Parallel execution:**
```
# Planning session continues in current worktree
# Execution happens in separate worktree with separate agent
# User can monitor both or switch between them
```

**Epic scope:**
```
# Agent only works on issues under the specified epic
# Other epics in the repo remain untouched
```

## Integration with Other Skills

- **After `/bdplan`**: Create the worktree and start execution
- **Before `/session-close`**: Optionally spawn agent before ending planning session
- **With `/jujutsu`**: Uses jj worktrees for clean isolation

## Notes

- The current session does NOT switch — you stay in the planning workspace
- The agent runs autonomously in the background
- Multiple agents can run in parallel (different worktrees/epics)
- Use `tmux list-sessions` to see all active agent sessions
- The worktree is a sibling directory, not a subdirectory of the main repo
