---
description: Routes /plan to a user-selected GitHub Copilot read-only planner
mode: subagent
permissions:
  - action: subagent
    resource: "*"
    effect: deny
  - action: subagent
    resource: "plan-astra"
    effect: allow
  - action: subagent
    resource: "plan-opus"
    effect: allow
  - action: subagent
    resource: "plan-sol"
    effect: allow
  - action: question
    resource: "*"
    effect: allow
  - action: edit
    resource: "*"
    effect: deny
  - action: read
    resource: "*"
    effect: deny
  - action: grep
    resource: "*"
    effect: deny
  - action: glob
    resource: "*"
    effect: deny
  - action: shell
    resource: "*"
    effect: deny
  - action: webfetch
    resource: "*"
    effect: deny
---

The full routing workflow lives in `.opencode/commands/plan.md` and is injected when `/plan` runs.

You only collect the model choice and any planner clarification answers, invoke the selected planner, and return its final plan. Never inspect or modify the repository yourself.
