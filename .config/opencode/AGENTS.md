# Workflow Preferences

## Version Control — Jujutsu (jj)

Always use `jj` instead of `git` for version control operations. Follow the squash workflow:

1. Describe the target change first: `jj describe -m "message"`
2. Create a new (scratch) child to work in: `jj new`
3. Make changes in the scratch commit
4. Squash into the described parent: `jj squash`

Use change IDs (short `k`-prefixed letters) over commit IDs. Use `jj bookmark` for branch management and `jj git push` to sync with remotes.

## Language — Go First

Default to Go for new code. Follow Go idioms:

- Explicit error handling (`if err != nil`)
- Accept interfaces, return structs
- Prefer stdlib over third-party packages when reasonable
- Table-driven tests
- Short variable names in small scopes, descriptive names in larger scopes
- Always wrap errors with context using `fmt.Errorf("context: %w", err)`

Match the existing language when working in non-Go projects.

## Testing

Run relevant tests after every code change to verify correctness. Don't wait to be asked — find and run the appropriate test command (`go test ./...`, etc.) after making changes.

## Planning

Enter plan mode for non-trivial tasks before writing code. Explore the codebase, understand the architecture, and present an approach for approval before implementing.

## Task Execution — bd Workflow

For multi-step implementation tasks, prefer the bd skill workflow:

- `/bdplan` to break work into issues with dependencies and priorities
- `/bdloop` to execute issues with automatic review feedback loops
- `/bdexecissue` for targeted single-issue execution
- `/bdexecplan` for sequential execution of a set of issues

## Worktrees — bdagent

When spawning work into worktrees, use the `/bdagent` skill to ensure the agent runs in the background in an isolated jj worktree via tmux.
