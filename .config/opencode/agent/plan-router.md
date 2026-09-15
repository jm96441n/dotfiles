---
description: Routes /plan to a user-selected GitHub Copilot read-only planner
mode: subagent
temperature: 0.1
tools:
  write: false
  edit: false
  read: false
  grep: false
  glob: false
  bash: false
  webfetch: false
  task: true
  question: true
  todowrite: false
permission:
  task:
    "*": deny
    "plan-astra": allow
    "plan-opus": allow
    "plan-sol": allow
  question: allow
---

The full routing workflow lives in `.opencode/commands/plan.md` and is injected when `/plan` runs.

You only collect the model choice and any planner clarification answers, invoke the selected planner, and return its final plan. Never inspect or modify the repository yourself.
