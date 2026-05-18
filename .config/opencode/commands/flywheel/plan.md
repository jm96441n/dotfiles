---
description: Flywheel Stage 1 — turn a rough concept into a polished, multi-model-synthesized markdown plan
argument-hint: <rough concept seed>
subtask: true
tools:
  task: true
  question: true
  bash: true
  read: true
  write: true
  glob: true
  edit: true
---

You orchestrate the Flywheel planning stage (https://agent-flywheel.com/complete-guide §3): rough concept → multi-model plans → "best of all worlds" synthesis → iterative refinement loop. The output is a comprehensive markdown plan suitable for downstream conversion to bd issues.

The blog post emphasizes: **planning is 85% of the work**. Models reason far better about a 6,000-line plan that fits in context than about a sprawling codebase. Plan-space corrections cost ~1x; bead-space ~5x; code-space ~25x. Earn your correctness here.

## Inputs

- `$ARGUMENTS`: optional rough concept (free-form). May be empty.

## Tools available

- `question` — for all user interaction
- `task` with `subagent_type: superPlan` — for multi-model planning + synthesis
- `bash`, `read`, `write`, `glob`, `edit` — for repo inspection and saving artifacts

## Core rules

- Stay read-only on existing source code. The only file you write is the plan markdown under `.opencode/plans/`.
- Every multi-model synthesis point goes through `/superplan` via the Task tool. Do not inline that logic.
- All user interaction goes through you — `/superplan` itself will run its own intake; you wrap it with the flywheel-specific framing.
- Do not skip the foundation check. Weak foundations leak uncertainty into every later stage.
- Do not auto-loop refinement rounds. Always ask between rounds — convergence is a judgment call.

## Workflow

### Step 0: Foundation check

Before any planning, verify the project has the foundation bundle the blog calls out (AGENTS.md, best-practices guides, tech stack baseline).

1. Run `ls AGENTS.md README.md` and check what exists.
2. If `AGENTS.md` is missing, issue a `question`:
   - `header`: `"Foundation: AGENTS.md"`
   - `question`: `"AGENTS.md is missing. The blog post strongly recommends bootstrapping it from a known-good template before planning, because every later stage inherits assumptions from it. How do you want to proceed?"`
   - `options`:
     - `Continue without AGENTS.md (I accept the risk)`
     - `Pause — I'll create AGENTS.md and re-run /flywheel/plan (Recommended)`
3. If the user pauses, stop here and tell them to come back.

### Step 1: Concept intake

Issue a single `question` tool call with **four** questions:

1. **Concept** (`header: "Concept"`)
   - question: "Describe what you want to build. A messy stream-of-thought is fine — explain what it is, who uses it, what makes it valuable, and any rough workflows you have in mind. The more intent and end-goal context you give, the better the resulting plan."
   - options:
     - If `$ARGUMENTS` is non-empty: `Use: "<$ARGUMENTS>" (Recommended)` — accept the seed
     - `Skip — I'll type a different concept`

2. **Tech stack** (`header: "Tech stack"`)
   - question: "What's the implementation target? The blog defaults to TypeScript/Next.js/React/Tailwind/Supabase for web apps and Go or Rust for CLIs. If you don't know, the planners can recommend one."
   - options:
     - `Web app — TypeScript / Next.js / React / Tailwind / Supabase`
     - `CLI — Go (Recommended for HashiCorp projects)`
     - `CLI — Rust`
     - `Library / package — let planners recommend`
     - `Skip — let the planners decide based on the concept`

3. **Project type** (`header: "Project type"`)
   - question: "Is this a brand-new project or extending an existing codebase?"
   - options:
     - `Greenfield — empty repo or new component (Recommended)`
     - `Extending this codebase — planners should ground in existing code`

4. **Refinement intensity** (`header: "Refinement intensity"`)
   - question: "After the initial multi-model plan, how aggressive should the refinement loop be? Each round runs /superplan again with the current plan and asks for revisions. Blog says 4–5 rounds is typical, with diminishing returns after."
   - options:
     - `Ask me between each round (Recommended)`
     - `Run 3 rounds then stop`
     - `Run 5 rounds then stop`
     - `Skip refinement — single synthesis pass only`

Wait for the user's batch response. Do not turn intake into a multi-turn interview — one round-trip only. If the user picks `Skip` on Concept, prompt once more for the actual concept (this is the only field where Skip cannot be N/A).

### Step 2: Initial multi-model plan via /superplan

Invoke the Task tool with `subagent_type: superPlan`. The prompt is the verbatim flywheel-style brief:

> Produce a comprehensive markdown plan for the project described below, using the Flywheel methodology (agent-flywheel.com/complete-guide §3).
>
> **Concept:** `<verbatim concept from Step 1>`
>
> **Tech stack:** `<verbatim from Step 1>`
>
> **Project type:** `<verbatim from Step 1>`
>
> **Goal:** Generate a plan detailed enough that an agent swarm can execute it without re-deriving architecture. The blog notes plans created this way "routinely reach 3,000–6,000+ lines" and are "the result of countless iterations and feedback from many frontier models."
>
> **The plan must include:**
>
> - Architecture overview (components, boundaries, data flow)
> - User-visible workflows in concrete terms (not "users can search" but "users type a query, the system parses tags, results return ranked by ...")
> - Tech stack rationale and major library choices
> - Edge cases and failure modes
> - Testing strategy (unit + e2e with detailed logging)
> - Auth, permissions, and security model
> - Deployment / rollout considerations
> - Operational concerns (logging, metrics, admin tools)
>
> **Anti-slop instructions:** Do not produce vague brainstorming. Each section must make the system legible. Avoid placeholder abstractions and compatibility shims. Debate architectural tradeoffs explicitly — that is what plan-space is for. Plans of 3000+ lines are normal and expected for non-trivial projects.
>
> **Synthesis intent:** Three planners produce independent plans. Take the strongest section from each — architecture from one, sequencing from another, validation from a third. This is the "best of all worlds" pattern from the blog: artfully blend complementary strengths so the merged plan is harder to surprise later than any individual planner's output.
>
> Produce the merged plan as the body of the final answer. The plan itself should be the final output, not a meta-summary.

Wait for `/superplan` to return.

### Step 3: Save initial plan

1. Slugify the concept the same way `/superplan` does:
   - lowercase, strip punctuation, collapse whitespace and non-alphanumerics to single hyphens, trim, truncate to 60 chars, trim trailing hyphen.
   - Suffix `-plan-v1`. Example: concept "Atlas Notes — internal markdown notes app" → `atlas-notes-internal-markdown-notes-app-plan-v1.md`.
2. Ensure `.opencode/plans/` exists (`mkdir -p`).
3. Check for collision. If `<slug>-plan-v1.md` already exists, ask via `question`:
   - `header`: `"Plan file collision"`
   - options: `Overwrite`, `Save as <slug>-plan-v1-alt.md (Recommended)`, `Cancel`
4. Write the merged plan body from `/superplan` (everything under "## Merged Plan" through end) to the file. Strip `/superplan`'s "What Each Planner Proposed" / "Pros And Cons" / "Final Assumptions" boilerplate — the plan file should be a pure plan, not a synthesis report. Keep the synthesis report visible in your inline output to the user.
5. Tell the user the path.

### Step 4: Refinement loop

Track the round counter (current round = 1 after initial plan).

Loop:

1. **Decide whether to refine.** Based on the user's Step 1 refinement intensity choice:
   - `Ask me between each round`: issue a `question` with `header: "Refinement round <N+1>?"`, `options`:
     - `Run another refinement round (Recommended for round ≤ 5)` — proceed to step 4.2
     - `Run 'overshoot mismatch hunt' instead` — see step 4.3
     - `Stop — the plan is good enough` — exit loop
   - `Run 3 rounds then stop`: auto-continue until N=3, then exit
   - `Run 5 rounds then stop`: auto-continue until N=5, then exit
   - `Skip refinement`: exit loop immediately

2. **Standard refinement round.** Invoke `/superplan` again via Task tool. Brief:

   > This is refinement round `<N+1>` of an existing Flywheel plan (agent-flywheel.com/complete-guide §3).
   >
   > **Refinement prompt (verbatim from blog):** Carefully review this entire plan for me and come up with your best revisions in terms of better architecture, new features, changed features, etc. to make it better, more robust/reliable, more performant, more compelling/useful, etc. For each proposed change, give me your detailed analysis and rationale/justification for why it would make the project better along with the git-diff style changes relative to the original markdown plan shown below.
   >
   > **Anti-laziness:** The blog notes models tend to stop looking for problems after finding ~20-25 issues. Find every single problem, every architectural weakness, every missing feature. There is no quota. The 'lie to them' technique applies — assume there are dozens of issues you have not yet surfaced.
   >
   > **Output:** produce the fully-revised plan as the body of your final answer. Each planner integrates its own revisions, and you (the orchestrator) synthesize the best revisions across all three planners into one plan that is strictly better than the input.
   >
   > **Current plan to refine:**
   >
   > ```markdown
   > <verbatim contents of the latest plan file>
   > ```

   After it returns, save to `<slug>-plan-v<N+1>.md` (collision-handle as before). Increment N.

   Show the user a brief diff summary (line count delta + section changes) so they can judge convergence.

3. **Overshoot mismatch hunt** (alternative to standard refinement). Invoke `/superplan` with brief:

   > Verbatim from blog "Overshoot Mismatch Hunt":
   >
   > Do this again, and actually be super super careful: can you please check over the plan again and compare it to all that feedback I gave you? I am positive that you missed or screwed up at least 80 elements of that complex feedback.
   >
   > Apply this to the plan below. The "80 elements" framing is a deliberate forcing function from the blog — it pressures models past their satisficing point. Find every issue, omission, contradiction, missing edge case, and unstated assumption. Produce the revised plan.
   >
   > **Plan:**
   >
   > ```markdown
   > <verbatim contents of latest plan file>
   > ```

   Save as `<slug>-plan-v<N+1>.md`. Increment N.

4. **Convergence heuristics.** After each saved version, surface to the user (do not block the loop, just inform):
   - Line count delta vs. previous version (shrinking is a convergence signal)
   - Whether structural sections (top-level headings) changed (decreasing structural change is a signal)
   - "If the last two rounds produced mostly incremental changes, the blog suggests you have reached steady-state."

### Step 5: Final output

Once the loop exits, print:

```
**Plan finalized:** `.opencode/plans/<slug>-plan-vN.md`

Refinement rounds run: <N>
Final line count: <count>

Next step: convert this plan into bd issues with:

    /flywheel/beads .opencode/plans/<slug>-plan-vN.md

The blog warns of the "plan-bead gap" — the failure mode where the plan is polished but never converted. Do not skip this step.
```

Tell the user nothing else. The plan file is the artifact.

## Failure modes to watch for

- **Plan-bead gap:** users sometimes refine forever and never convert. Surface the next-step pointer aggressively.
- **`/superplan` collision warnings:** since `/superplan` writes its own files under `.opencode/plans/`, your slug naming uses `-plan-vN` as a distinct suffix to avoid collision with `/superplan`'s default `<slug>.md` outputs.
- **Empty `/superplan` output:** if a planner round returns nothing usable, do not increment the version counter. Surface the failure to the user and ask whether to retry or abort.
- **User wants to stop mid-flow:** every `question` includes a `Cancel` / `Stop` option where appropriate.
