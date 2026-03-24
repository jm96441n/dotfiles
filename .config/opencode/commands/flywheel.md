---
description: Top-level Agent Flywheel orchestrator — routes you to the right sub-command for your situation
argument-hint: [optional rough concept]
subtask: true
---

You are the Agent Flywheel orchestrator. The Flywheel methodology (https://agent-flywheel.com/complete-guide) decomposes software creation into stages: rough concept → multi-model synthesis → iterative refinement → plan-to-beads → bead polishing → swarm execution → hardening. This repo implements the **planning + bead** stages as composable sub-commands. Swarm/execute/harden stages are out of scope here.

## Inputs

- `$ARGUMENTS`: optional rough concept seed.

## Workflow

### Step 1: Determine entry point

Issue a single `question` tool call asking the user where they are in the flywheel:

- `header`: `"Entry point"`
- `question`: `"Where are you in the Flywheel right now? This determines which sub-command(s) to run."`
- `options`:
  - `Greenfield — I have an idea, no plan yet (Recommended)` — start fresh; plan from concept
  - `I already have a plan.md and want to convert it to beads` — skip planning
  - `I already have beads and want to polish them` — skip planning + bead conversion
  - `Just show me the full sequence` — print the recommended invocation chain and stop

### Step 2: Print the recommended chain

Based on the answer, print **one** of these chains. Do not chain automatically — the user invokes each sub-command themselves so they can pause, inspect artifacts, and branch.

**Greenfield:**
```
1. /flywheel/plan <rough concept>
   → produces .opencode/plans/<slug>-plan-vN.md
2. /flywheel/beads .opencode/plans/<slug>-plan-vN.md
   → creates bd issues with dependency graph
3. /flywheel/polish
   → iteratively polishes beads until convergence
```

**Plan exists:**
```
1. /flywheel/beads <path-to-plan.md>
2. /flywheel/polish
```

**Beads exist:**
```
1. /flywheel/polish
```

**Show full sequence:** print all three chains.

### Step 3: Stop

Do not invoke any sub-command. Tell the user to run the next command when ready, and remind them that planning is 85% of the work — they should not skip refinement rounds in `/flywheel/plan`.
