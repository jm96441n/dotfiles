# Workflow Preferences

ALWAYS BE BRIEF

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
- Comments should BE BRIEF, keep them to the minimum necessary to explain the "why" of the code, not the "what"

Match the existing language when working in non-Go projects.

## Testing

Run relevant tests after every code change to verify correctness. Don't wait to be asked — find and run the appropriate test command (`go test ./...`, etc.) after making changes.

## Planning

Enter plan mode for non-trivial tasks before writing code. Explore the codebase, understand the architecture, and present an approach for approval before implementing. Utilize the codegraph mcp
server to build context of the repository.

## Task Execution — bd Workflow

For multi-step implementation tasks, prefer the bd skill workflow:

- `/bdplan` to create or extend epic -> story -> checkpoint plans with explicit dependencies
- `/bdloop` to execute a scoped plan with automatic review feedback loops
- `/bdexecissue` for targeted single-issue execution
- `/bdexecplan` to execute an epic, story, or issue scope

## PR Responses

When asked to address comments on a PR DO NOT respond to the comments, let the user write their own response. Instead, make the requested changes and push them to the PR. The user will then review and respond to the changes.
