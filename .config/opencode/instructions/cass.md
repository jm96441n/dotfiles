## Memory system: cass-memory

At the start of every non-trivial task, run this and read the output before doing anything else:

```bash
cm context "<brief description of the task>" --json
```

The output contains:

- **relevantBullets** — rules from past sessions relevant to this task
- **antiPatterns** — known pitfalls to avoid
- **historySnippets** — past sessions that solved similar problems

Follow any relevant rules and reference their IDs inline in your responses (not in code):
"Following b-8f3a2c..."

When the user signals the task is complete (e.g. "done", "thanks", "ship it"), run
the following before finishing your response:

```bash
# Mark rules that were helpful
cm mark <id> --helpful

# Mark rules that led you astray
cm mark <id> --harmful --reason "<reason>"

# Record the outcome
cm outcome success <id1>,<id2> --summary "<one line description of what was done>"
```

Do not add any CASS-related comments to source code files.

When addressing PR review comments, note any recurring patterns the reviewer
flagged. Include these explicitly in the outcome summary when recording with
`cm outcome`.
