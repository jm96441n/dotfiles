---
description: Flywheel Stage 3 — iteratively polish bd issues until convergence ("Check your beads N times, implement once")
argument-hint: [optional max round count]
subtask: true
---

You orchestrate Flywheel bead polishing (https://agent-flywheel.com/complete-guide §5). The blog's maxim: **"Check your beads N times, implement once,"** where N is as many as you can stomach. This is the step most people underinvest in. Each polishing round finds things the previous round missed: duplicates, missing dependencies, incomplete context, undertested obligations.

Convergence usually takes 4–6+ rounds. Above 12 rounds you are hitting diminishing returns. The blog's convergence signals: agent responses shrinking, change rate decelerating, successive rounds becoming similar.

Note: blog uses `br` (beads_rust). This repo uses `bd` (beads). Substituted throughout.

## Inputs

- `$ARGUMENTS`: optional max round count (default: ask each round, no cap).

## Tools available

- `question` — for round-by-round decisions
- `task` with `subagent_type: beads-task-agent` — for actual polishing work (per AGENTS.md, multi-`bd`-command work goes through this agent)
- `bash` — for stats / convergence detection

## Workflow

### Step 0: Pre-flight

1. Verify `bd` is initialized: `bd stats --json`. Bail with a helpful error if not.
2. Snapshot baseline:
   ```
   bd stats --json
   bd list --status=open --json | jq 'length'
   bd blocked --json | jq 'length'
   ```
3. If open bead count is 0, ask via `question`:
   - `header`: `"No open beads"`
   - `question`: `"There are no open bd issues to polish. Did you run /flywheel/beads first?"`
   - `options`: `Cancel`, `Continue anyway (I closed beads recently)`

### Step 1: Polish loop

Maintain state across rounds:
- `round`: integer, starts at 1
- `prev_open_count`, `prev_total_count`, `prev_dep_count`: from previous round's snapshot
- `rounds_run_so_far`: list of polish styles used

Loop:

#### 1a. Decide what to do this round

If `$ARGUMENTS` is a number and `round > $ARGUMENTS`, exit loop.

Otherwise issue a single `question`:

- `header`: `"Polish round <round>"`
- `question`: `"What style of polishing for round <round>? The blog suggests: standard polish for early rounds, dedup after batch creation, fresh-eyes when improvements flatline, final-pass with a different model class as a last sanity check."`
- `options`:
  - `Standard polish (Recommended for rounds 1-4)` — the main blog prompt
  - `Deduplication pass` — merge duplicate / overlapping beads
  - `Fresh eyes` — start as if you've never seen these beads before
  - `Cross-reference against plan` — verify nothing was lost in conversion
  - `Final pass (different reasoning model)` — last sanity check
  - `Stop polishing — beads are ready` — exit loop

#### 1b. Run the chosen polish style

Invoke Task tool with `subagent_type: beads-task-agent`. Use the verbatim prompt for the chosen style (all from the blog, with `br` → `bd` and `bv` → `bd ready` / `bd blocked` references):

##### Standard polish

> You are running Flywheel bead-polishing round <round> (agent-flywheel.com/complete-guide §5).
>
> **Verbatim Bead Polishing Prompt (from blog, `br` → `bd`):**
>
> Reread AGENTS.md so it's still fresh in your mind. Check over each bead super carefully — are you sure it makes sense? Is it optimal? Could we change anything to make the system work better for users? If so, revise the beads. It's a lot easier and faster to operate in "plan space" before we start implementing these things! DO NOT OVERSIMPLIFY THINGS! DO NOT LOSE ANY FEATURES OR FUNCTIONALITY! Also, make sure that as part of these beads, we include comprehensive unit tests and e2e test scripts with great, detailed logging so we can be sure that everything is working perfectly after implementation. Remember to ONLY use the `bd` tool to create and modify the beads and to add the dependencies to beads. Use ultrathink.
>
> **bd CLI reference:**
> ```
> bd list --status=open --json
> bd show <id> --json
> bd update <id> --description "..." --notes "..."
> bd dep add <id> <depends-on>
> bd label add <id> <label>
> bd comments add <id> "..."
> bd close <id> --reason "..."          # for duplicates / obsoleted beads
> bd create --title --description --type --priority    # if missing beads found
> ```
>
> **Anti-laziness:** the blog notes models stop looking after ~20-25 issues. Push past that. Use the "lie to them" technique mentally — assume there are dozens of beads with subtle problems you have not yet found. The goal is no oversimplification and no lost functionality.
>
> When done, return: count of beads modified, count of beads added, count of beads closed, count of dependency edges added, list of changes by category.

##### Deduplication pass

> You are running a Flywheel bead deduplication pass (agent-flywheel.com/complete-guide §5).
>
> **Verbatim Bead Deduplication prompt (from blog, `br` → `bd`):**
>
> Reread AGENTS.md so it's still fresh in your mind. Check over ALL open beads. Make sure none of them are duplicative or excessively overlapping... try to intelligently and cleverly merge them into single canonical beads that best exemplify the strengths of each.
>
> **Method:** for each pair you merge:
> 1. Pick the survivor (richer testing specs, better dependency chains, higher priority — per the blog's FrankenSQLite pattern that found 9 exact duplicate pairs).
> 2. Move any unique content from the loser into the survivor's description/notes.
> 3. Re-point dependencies: any bead depending on the loser should now depend on the survivor; same for beads the loser depended on.
> 4. `bd close <loser> --reason "merged into <survivor> as duplicate"`.
>
> Use ONLY the `bd` tool. Return: count of pairs merged, count of dependency edges re-pointed.

##### Fresh eyes

This is a two-step prompt sequence per the blog. Do both in one Task invocation:

> You are running a Flywheel "fresh eyes" review (agent-flywheel.com/complete-guide §5).
>
> **Verbatim step 1 (from blog):** First read ALL of the AGENTS.md file and README.md file super carefully and understand ALL of both! Then use your code investigation agent mode to fully understand the code, and technical architecture and purpose of the project. Use ultrathink.
>
> **Verbatim step 2 (from blog, `br`/`bv` → `bd`):** We recently transformed a markdown plan file into a bunch of new beads. I want you to very carefully review and analyze these using `bd`. Check over each bead super carefully-- are you sure it makes sense? Is it optimal? Could we change anything to make the system work better for users? If so, revise the beads. It's a lot easier and faster to operate in "plan space" before we start implementing these things! Use ultrathink.
>
> Use ONLY the `bd` tool. Return what you found and what you changed.

##### Cross-reference against plan

Before invoking, ask the user via `question` for the plan path if you don't already have it from session context.

> You are running a Flywheel plan-to-beads cross-reference audit.
>
> **Plan file:** `<plan path>`
>
> **Method (from blog):** go through the markdown plan and cross-reference every single thing against the beads (both closed and open) to ensure complete coverage. Then go through each bead and check it explicitly against the plan to ensure it carries the right context.
>
> **Anti-laziness — the "lie to them" technique:** I am positive you missed or screwed up at least 80 elements when comparing the plan and beads. Find every concept in the plan that is missing or under-represented in the beads. Find every bead that drifted from what the plan actually says.
>
> For every gap: either create a new bead (`bd create`), or update an existing one (`bd update --description` or `bd comments add`).
>
> Use ONLY the `bd` tool. Return: list of plan concepts not represented in beads (and what you did about each), list of beads that drifted from the plan (and what you did).

##### Final pass

> You are running the Flywheel final polish pass (agent-flywheel.com/complete-guide §5).
>
> The blog recommends this as a last round, ideally with a different model class than earlier rounds caught the things they didn't. Apply the same standard polish prompt with maximum rigor:
>
> Reread AGENTS.md. Check over each bead super carefully — are you sure it makes sense? Is it optimal? Could we change anything to make the system work better for users? If so, revise the beads. DO NOT OVERSIMPLIFY THINGS! DO NOT LOSE ANY FEATURES OR FUNCTIONALITY! Make sure tests and dependency edges are complete. Remember to ONLY use the `bd` tool. Use ultrathink.
>
> Treat this as the last chance to catch issues before implementation. Be more skeptical than in previous rounds.

#### 1c. Snapshot and report convergence

After the Task returns:

```
bd stats --json
bd list --status=open --json | jq 'length'
bd blocked --json | jq 'length'
```

Compute deltas vs. previous round:
- `open_count_delta`
- `total_count_delta` (created + reopened - closed)
- `dep_count_delta`

Print to user:

```
Round <round> complete (<style>).
- Open beads: <prev> → <now> (Δ <delta>)
- Dependency edges: <prev> → <now> (Δ <delta>)
- Convergence signal: <verdict>
```

Convergence verdict logic:
- If `|open_count_delta| ≤ 2` and `|dep_count_delta| ≤ 5` and round ≥ 3: `"Looks like steady-state — consider stopping."`
- If `open_count_delta < 0` (beads being closed/merged): `"Still finding duplicates — keep polishing."`
- If `open_count_delta > 5`: `"Round expanded scope — this is normal in early rounds but a red flag after round 6."`
- If round = 1: `"Baseline — too early to detect convergence."`
- If round > 12: `"Diminishing returns territory per the blog — strongly consider stopping."`

Update state and increment `round`. Loop.

### Step 2: Final output

When the loop exits, print:

```
**Polishing complete.**

Rounds run: <round - 1>
Polish styles used: <list>
Final open bead count: <N>
Final dependency edges: <count>

The blog says: "Once you have the beads in good shape based on a great markdown plan, I almost view the project as a foregone conclusion at that point. The rest is basically mindless 'machine tending' of your swarm."

Recommended next steps (out of scope for this command family):
- Manual sanity scan of `bd ready` — pick 1-2 beads and read them as if you were a fresh agent. Are they self-contained? Do they have test obligations?
- Implementation can begin via your normal agent workflow.
```

## Failure modes

- **Loop never exits because user keeps clicking continue:** at round 13+, surface a stronger warning.
- **Polish made things worse:** if `open_count_delta > 20` in a single round, ask the user: "this round expanded scope a lot — did the agent oversimplify and split beads, or did it find legitimate missing work? Want to inspect before continuing?"
- **`beads-task-agent` returns without making changes:** if all deltas are zero for two consecutive rounds and the user hasn't said stop, that's natural convergence. Recommend stopping.
- **Plan path lost on cross-reference:** if the user can't recall the plan path and `.opencode/plans/` has multiple files, list them and let the user pick via `question`.
