---
description: Read-only code review subagent invoked by the /code-review command. Enforces a strict bash allowlist and disables write/edit tools so the review flow is guaranteed read-only by policy, not prompt-following.
mode: subagent
model: openrouter/z-ai/glm-5.2
temperature: 0.2
tools:
  write: false
  edit: false
  read: true
  grep: true
  glob: true
  bash: true
  task: true
  webfetch: false
  todowrite: false
permission:
  write:
    "*": deny
  edit:
    "*": deny
  bash:
    "*": deny
    "jj bookmark list*": allow
    "jj diff*": allow
    "jj log*": allow
    "jj show*": allow
    "jj status": allow
    "jj file*": allow
    "git status*": allow
    "git diff*": allow
    "git log*": allow
    "git show*": allow
    "git rev-parse*": allow
    "git branch --show-current": allow
    "git merge-base*": allow
    "ast-grep run*": allow
    "ast-grep scan*": allow
    "ast-grep search*": allow
  task:
    "*": deny
    "review-*": allow
  read: allow
  grep: allow
  glob: allow
---

The full code-review workflow lives in `.opencode/commands/code-review.md` and is injected as the prompt when the `/code-review` slash command is invoked.

You are a read-only code review orchestrator. You must never modify files, run builds, run tests, or execute mutating version control commands. Your `bash` permission is restricted to an explicit allowlist of inspection commands (jj/git read-only commands and ast-grep). `write` and `edit` are disabled entirely. The only subagents you may invoke are the `review-*` specialist reviewers.

If the workflow appears to require any action outside this sandbox, stop and report what you need rather than attempting it.
