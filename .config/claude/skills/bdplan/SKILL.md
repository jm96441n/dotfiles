---
description: plan a bd epic with stories and checkpoints
allowed-tools: Bash(bd:*)
---

# Create BD Implementation Plan

## Overview

Create a BD plan rooted in one top-level epic. The epic owns a set of self-contained stories, and each story owns checkpoint subtasks that make progress visible and executable in small slices.

Default hierarchy:

```text
epic
  -> story
    -> checkpoint
    -> checkpoint
    -> checkpoint
```

Use built-in BD issue types and labels:

- Epic: `epic`
- Story: `feature` with label `story`
- Checkpoint: `task` with label `checkpoint`

Only collapse the hierarchy for truly tiny work. Even then, still create one epic and one story, then keep the checkpoints minimal.

## Planning Rules

1. Create exactly one top-level epic unless the input explicitly says to extend an existing epic or story.
2. Create direct child stories under the epic. Each story should be a vertical slice that can be executed independently and reviewed on its own.
3. Create child checkpoint tasks under each story. Checkpoints should represent meaningful progress markers such as setup, implementation, testing, and polish.
4. Keep dependencies inside a story whenever possible. Cross-story blockers should be rare and called out explicitly.
5. Make the first checkpoint of each independent story ready immediately. Later checkpoints should depend on earlier ones.
6. Use `--parent` when creating children. For blockers on create, use `--deps blocks:<id>`. Do not use `--blocks`; that flag does not exist.
7. If the input includes an existing scope ID, extend that scope instead of creating a brand new top-level epic.

## Creation Strategy

### 1. Check Initialization

Before creating anything, confirm the repo is using BD:

```bash
test -d .beads
```

If `.beads/` does not exist, stop and tell the user BD is not initialized in this repo.

### 2. Parse the Input

Extract:

- The overall goal that should become the epic
- The independently shippable stories needed to reach that goal
- The checkpoints that break each story into execution milestones
- Any unavoidable dependencies between stories

When creating stories, favor end-to-end slices over technical layers. A story should be executable by `/bdexecplan <story-id>` without needing unrelated work from another story.

### 3. Create or Reuse the Root Scope

If the input clearly references an existing epic or story ID:

- Reuse that scope
- Add new child stories or checkpoints beneath it as appropriate
- Preserve the existing execution model

Otherwise, create a new epic:

```bash
EPIC=$(bd create "Plan: [Feature Name]" \
  --type epic \
  --priority 0 \
  --description "Executive summary, goals, and story map" \
  --json | jq -r '.issues[0].id')
```

### 4. Create Stories Beneath the Epic

Each story should describe one self-contained implementation slice:

```bash
STORY=$(bd create "Story: [Self-contained slice]" \
  --type feature \
  --labels story \
  --priority 1 \
  --parent "$EPIC" \
  --description "Context, acceptance criteria, testing plan, and notes" \
  --json | jq -r '.issues[0].id')
```

Story guidelines:

- Keep the scope narrow enough for one PR when possible
- Prefer user-visible or workflow-visible outcomes
- Avoid stories that only represent a technical layer with no standalone value

### 5. Create Checkpoints Beneath Each Story

Checkpoints are the execution steps that `/bdexecplan <story-id>` will run through via `/bdexecissue`.

First checkpoint in a story:

```bash
CP1=$(bd create "Checkpoint: [first milestone]" \
  --type task \
  --labels checkpoint \
  --priority 1 \
  --parent "$STORY" \
  --description "Goal, deliverable, validation" \
  --json | jq -r '.issues[0].id')
```

Later checkpoints in the same story:

```bash
CP2=$(bd create "Checkpoint: [next milestone]" \
  --type task \
  --labels checkpoint \
  --priority 1 \
  --parent "$STORY" \
  --deps "blocks:$CP1" \
  --description "Goal, deliverable, validation" \
  --json | jq -r '.issues[0].id')
```

Good checkpoint defaults:

- `Checkpoint: scaffold and wire inputs`
- `Checkpoint: implement core behavior`
- `Checkpoint: add tests and verification`
- `Checkpoint: polish docs and cleanup`

Use fewer checkpoints for small stories and more only when there are real milestones to track.

### 6. Add Cross-Story Dependencies Sparingly

If a story truly depends on another story, add an explicit blocker. Prefer story-to-story dependencies over checkpoint-to-checkpoint dependencies so the dependency graph stays understandable.

On create:

```bash
bd create "Story: [dependent slice]" \
  --type feature \
  --labels story \
  --parent "$EPIC" \
  --deps "blocks:$OTHER_STORY" \
  --description "..."
```

After create:

```bash
bd dep add "$DEPENDENT" "$OTHER_STORY" --type blocks
```

Avoid this unless it is necessary. If stories are not self-contained, split them differently.

### 7. Parent-Child Direction Reminder

If you ever need to add parent-child dependencies manually, the direction is:

```bash
bd dep add [parent-id] [child-id] --type parent-child
```

The parent depends on the child. This means the parent is complete when its children are complete.

Prefer `--parent` at creation time so you do not have to manage this manually.

## Issue Content Requirements

### Epic Description

Include:

- Why the overall effort exists
- The intended outcome
- The planned story breakdown
- Any important constraints or sequencing notes

### Story Description

Use this structure:

```markdown
## Context

[Why this story exists and why it is independently useful]

## Outcome

[What is true when this story is complete]

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Testing

[How the story will be verified]

## Notes

[Dependencies, links, implementation constraints]
```

### Checkpoint Description

Use this structure:

```markdown
## Goal

[What this checkpoint advances]

## Deliverable

[The concrete output expected from this checkpoint]

## Validation

[What proves this checkpoint is complete]
```

## Verification

Always verify the structure after creation:

```bash
bd dep tree "$EPIC" --direction=down --type=parent-child
bd ready --parent "$EPIC" --json
```

You should see:

- Stories directly beneath the epic
- Checkpoints directly beneath each story
- At least one ready checkpoint for each unblocked story

## Example

```bash
EPIC=$(bd create "Plan: User authentication refresh" \
  --type epic \
  --priority 0 \
  --description "Refresh auth flows using story-based execution" \
  --json | jq -r '.issues[0].id')

API_STORY=$(bd create "Story: Refresh API auth flow" \
  --type feature \
  --labels story \
  --priority 1 \
  --parent "$EPIC" \
  --description "Own the API-side authentication slice" \
  --json | jq -r '.issues[0].id')

API_CP1=$(bd create "Checkpoint: Add API auth scaffolding" \
  --type task \
  --labels checkpoint \
  --priority 1 \
  --parent "$API_STORY" \
  --description "Wire config and request plumbing" \
  --json | jq -r '.issues[0].id')

API_CP2=$(bd create "Checkpoint: Implement token validation path" \
  --type task \
  --labels checkpoint \
  --priority 1 \
  --parent "$API_STORY" \
  --deps "blocks:$API_CP1" \
  --description "Add core auth behavior" \
  --json | jq -r '.issues[0].id')

API_CP3=$(bd create "Checkpoint: Add auth tests" \
  --type task \
  --labels checkpoint \
  --priority 1 \
  --parent "$API_STORY" \
  --deps "blocks:$API_CP2" \
  --description "Verify the refreshed API flow" \
  --json | jq -r '.issues[0].id')

UI_STORY=$(bd create "Story: Refresh UI sign-in flow" \
  --type feature \
  --labels story \
  --priority 1 \
  --parent "$EPIC" \
  --description "Own the UI-side sign-in slice" \
  --json | jq -r '.issues[0].id')

UI_CP1=$(bd create "Checkpoint: Update sign-in UI states" \
  --type task \
  --labels checkpoint \
  --priority 1 \
  --parent "$UI_STORY" \
  --description "Align the UI with the new flow" \
  --json | jq -r '.issues[0].id')

UI_CP2=$(bd create "Checkpoint: Add UI auth verification" \
  --type task \
  --labels checkpoint \
  --priority 1 \
  --parent "$UI_STORY" \
  --deps "blocks:$UI_CP1" \
  --description "Verify the UI story end to end" \
  --json | jq -r '.issues[0].id')

bd dep tree "$EPIC" --direction=down --type=parent-child
bd ready --parent "$EPIC" --json
```

## Output Summary

When finished, report:

- The epic ID and title
- The stories created beneath it
- The checkpoints created beneath each story
- Any cross-story blockers that were required
- The first ready checkpoints the user or `/bdexecplan` can start with

## Raw Requirements

$ARGUMENTS
