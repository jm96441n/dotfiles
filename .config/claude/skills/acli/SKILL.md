---
name: acli
description: Work with Atlassian products (Jira and Confluence) using the Atlassian CLI. Use when the user needs to create, view, edit, search, or manage Jira work items, projects, boards, sprints, filters, or Confluence spaces. Also use for authentication, user management, or automation of Atlassian workflows.
---

# Atlassian CLI (acli)

Use the Atlassian CLI to interact with Jira and Confluence from the command line.

## Project-Specific Configuration

### InfraGraph Project (IG)

**Project Information:**
- **Project Key**: `IG`
- **Team Field**: `customfield_10001`
- **Default Team Value**: `InfraGraph-Graph Engine`

**Creating Issues:**

When creating Jira issues for the InfraGraph project, always include the team field:

```bash
# Create a task with team field
acli jira workitem create \
  --project IG \
  --type Task \
  --summary "Task summary" \
  --description "Task description" \
  --custom "customfield_10001=InfraGraph-Graph Engine"
```

**Linking to Epics:**

When creating issues under an epic, use the `--parent` flag. This automatically inherits the team field from the parent epic:

```bash
# Create a subtask under an epic (team field inherited)
acli jira workitem create \
  --project IG \
  --type Task \
  --summary "Subtask summary" \
  --description "Task description" \
  --parent IG-1234
```

**Note**: When linking to an epic via `--parent`, you don't need to explicitly set `customfield_10001` as it will be inherited from the parent.

## Authentication

### Authentication Methods

There are two ways to authenticate with acli:

**1. OAuth (Web Browser) - Global Authentication:**

```bash
# Authenticate globally via OAuth (opens browser)
acli auth login

# OR for Jira-specific OAuth
acli jira auth login --web
```

**2. API Token - Product-Specific Authentication:**

For organizations where OAuth is not enabled, use an API token:

```bash
# Authenticate with API token (Linux/Mac)
echo "your-api-token" | acli jira auth login --site "mysite.atlassian.net" --email "user@example.com" --token

# OR read token from file
acli jira auth login --site "mysite.atlassian.net" --email "user@example.com" --token < token.txt

# Windows users
Get-Content token.txt | .\acli.exe jira auth login --site "mysite.atlassian.net" --email "user@example.com" --token
```

To create an API token:

1. Go to https://id.atlassian.com/manage-profile/security/api-tokens
2. Click "Create API token"
3. Give it a name and copy the token
4. Use it with the `--token` flag as shown above

**Note:** API token authentication is product-specific (e.g., `acli jira auth login`), while OAuth can be global (`acli auth login`).

### Check Authentication Status

```bash
acli auth status
# OR for product-specific status
acli jira auth status
```

### Switch Between Accounts

```bash
acli auth switch
# OR for product-specific
acli jira auth switch
```

## Common Workflows

### Working with Jira Work Items

**Search for work items:**

```bash
# Find your assigned work items
acli jira workitem search --jql "assignee = currentUser() AND status != Done"

# Find work items by project
acli jira workitem search --jql "project = PROJ AND status = 'In Progress'"

# Search with specific fields and output formats
acli jira workitem search --jql "project = PROJ AND created >= -7d" --fields "key,summary,assignee" --csv

# Limit results or paginate through all
acli jira workitem search --jql "project = PROJ" --limit 50 --json
acli jira workitem search --jql "project = PROJ" --paginate

# Get count of matching work items
acli jira workitem search --jql "project = PROJ" --count

# Search using a saved filter
acli jira workitem search --filter 10001
```

**View work item details:**

```bash
acli jira workitem view KEY-123

# View specific fields only
acli jira workitem view KEY-123 --fields "summary,comment"

# View in JSON format
acli jira workitem view KEY-123 --json

# Open in web browser
acli jira workitem view KEY-123 --web
```

**Create a work item:**

```bash
# Create a task
acli jira workitem create --project PROJ --type Task --summary "Fix login bug"

# Create with description and assignee
acli jira workitem create --project PROJ --type Task --summary "Implement feature" --description "Detailed description here" --assignee "user@example.com"

# Self-assign with @me
acli jira workitem create --project PROJ --type Bug --summary "Fix crash" --assignee "@me" --label "bug,critical"

# Create with a parent (subtask)
acli jira workitem create --project PROJ --type Task --summary "Subtask" --parent KEY-100

# Create from a JSON file
acli jira workitem create --from-json "workitem.json"
```

**Edit a work item:**

```bash
# Edit summary
acli jira workitem edit --key "KEY-123" --summary "Updated summary"

# Edit multiple work items
acli jira workitem edit --key "KEY-1,KEY-2" --assignee "user@example.com"

# Edit work items matching a JQL query
acli jira workitem edit --jql "project = PROJ" --assignee "user@example.com" --yes
```

**Transition work item status:**

```bash
# Move to a different status
acli jira workitem transition --key "KEY-123" --status "In Progress"

# Transition multiple work items
acli jira workitem transition --key "KEY-1,KEY-2" --status "Done"

# Transition by JQL query
acli jira workitem transition --jql "project = PROJ" --status "In Progress" --yes
```

**Assign work item:**

```bash
# Assign to a user
acli jira workitem assign --key "KEY-123" --assignee "user@example.com"

# Self-assign
acli jira workitem assign --key "KEY-123" --assignee "@me"

# Remove assignee
acli jira workitem assign --key "KEY-123" --remove-assignee
```

**Link work items:**

```bash
# Create a link between work items
acli jira workitem link create --out KEY-123 --in KEY-456 --type Blocks

# List links on a work item
acli jira workitem link list --key KEY-123

# View available link types
acli jira workitem link type
```

**Clone work item:**

```bash
# Clone a work item
acli jira workitem clone --key "KEY-123"

# Clone to a different project
acli jira workitem clone --key "KEY-123" --to-project "OTHER"

# Clone multiple work items
acli jira workitem clone --key "KEY-1,KEY-2" --to-project "TEAM"
```

**Delete work item:**

```bash
# Delete a work item
acli jira workitem delete --key "KEY-123"

# Delete multiple work items
acli jira workitem delete --key "KEY-1,KEY-2" --yes

# Delete by JQL query
acli jira workitem delete --jql "project = PROJ AND status = Done" --yes
```

**Comments:**

```bash
# List comments
acli jira workitem comment list --key KEY-123

# Create a comment
acli jira workitem comment create --key KEY-123 --body "This is a comment"

# Update a comment
acli jira workitem comment update --key KEY-123 --comment-id 12345 --body "Updated comment"

# Delete a comment
acli jira workitem comment delete --key KEY-123 --comment-id 12345
```

**Attachments and watchers:**

```bash
# List attachments
acli jira workitem attachment list --key KEY-123

# List watchers
acli jira workitem watcher list --key KEY-123

# Remove a watcher
acli jira workitem watcher remove --key KEY-123 --account-id "user-account-id"
```

**Archive/unarchive:**

```bash
acli jira workitem archive --key "KEY-123"
acli jira workitem unarchive --key "KEY-123"
```

### Managing Jira Projects

**List projects:**

```bash
# List projects (default limit 30)
acli jira project list

# List all projects via pagination
acli jira project list --paginate

# List recently viewed projects
acli jira project list --recent

# Output as JSON
acli jira project list --limit 50 --json
```

**View project details:**

```bash
acli jira project view --key "PROJ"
acli jira project view --key "PROJ" --json
```

**Create project:**

```bash
# Create a project cloned from an existing project
acli jira project create --from-project "EXISTING" --key "NEWPROJ" --name "New Project"

# With optional fields
acli jira project create --from-project "EXISTING" --key "NEWPROJ" --name "New Project" --description "Project description" --lead-email "lead@example.com"

# Create from a JSON file
acli jira project create --from-json "project.json"

# Generate a JSON template for project creation
acli jira project create --generate-json
```

**Update project:**

```bash
# Update project description
acli jira project update --project-key "PROJ" --description "Updated description"

# Update project name and key
acli jira project update --project-key "PROJ" --name "New Name" --key "NEWKEY"
```

**Archive/restore projects:**

```bash
acli jira project archive --key "PROJ"
acli jira project restore --key "PROJ"
```

**Delete project:**

```bash
acli jira project delete --key "PROJ"
```

### Boards and Sprints

**Search boards:**

```bash
# Search by project
acli jira board search --project PROJ

# Search by name
acli jira board search --name "My Board"

# Filter by type
acli jira board search --type scrum
```

**List sprints for a board:**

```bash
# List all sprints for a board
acli jira board list-sprints --id 123

# Filter by sprint state
acli jira board list-sprints --id 123 --state active,closed
```

**Sprint management:**

```bash
# View sprint details
acli jira sprint view --id 456

# List work items in a sprint (both --sprint and --board are required)
acli jira sprint list-workitems --sprint 456 --board 123

# Create/update/delete sprints
acli jira sprint create -h
acli jira sprint update -h
acli jira sprint delete -h
```

### Filters

**List filters:**

```bash
# List my filters
acli jira filter list --my

# List my favourite filters
acli jira filter list --favourite
```

**Search filters:**

```bash
acli jira filter search --name "My Filter"
acli jira filter search --owner "user@example.com"
```

**Add filter to favourites:**

```bash
acli jira filter add-favourite --filter-id 10001
```

**Other filter commands:**

```bash
acli jira filter get --id 10001
acli jira filter update -h
acli jira filter change-owner -h
```

### Confluence

**Space management:**

```bash
# List spaces
acli confluence space list

# View space details
acli confluence space view --key "SPACE"

# Create a space
acli confluence space create -h

# Update a space
acli confluence space update -h

# Archive/restore a space
acli confluence space archive --key "SPACE"
acli confluence space restore --key "SPACE"
```

**Authentication (same patterns as Jira):**

```bash
acli confluence auth login --web
# OR with API token
echo "token" | acli confluence auth login --site "mysite.atlassian.net" --email "user@example.com" --token
```

### Administrative Tasks

**User management:**

```bash
# Admin auth (separate from product auth)
acli admin auth login

# User commands
acli admin user activate -h
acli admin user deactivate -h
acli admin user delete -h
acli admin user cancel-delete -h
```

### Dashboards and Fields

```bash
# Search dashboards
acli jira dashboard search -h

# Custom field management
acli jira field create -h
acli jira field delete -h
acli jira field cancel-delete -h
```

## Discovery Pattern

For any command, use the `-h` or `--help` flag to discover available options:

```bash
# Top-level help
acli -h

# Command-specific help
acli jira -h
acli jira workitem -h
acli jira workitem create -h
```

## Minimizing Output Size (Token Conservation)

acli returns raw Jira REST API v3 responses — it does not strip or transform the payload. This means
descriptions come back as Atlassian Document Format (ADF), a deeply nested JSON structure that can be
hundreds of lines for a single field. **Always filter output aggressively to avoid wasting tokens.**

### Use --fields to request only what you need

Both `workitem view` and `workitem search` support `--fields` to limit returned fields:

```bash
# View: only get summary and status (skips the massive ADF description, comments, etc.)
acli jira workitem view KEY-123 --fields "summary,status"

# View: get everything except description
acli jira workitem view KEY-123 --fields "-description"

# Search: only key, summary, and assignee
acli jira workitem search --jql "project = PROJ" --fields "key,summary,assignee"
```

**Default fields for `view`:** `key,issuetype,summary,status,assignee,description`
**Default fields for `search`:** `issuetype,key,assignee,priority,status,summary`

If you don't need the description, explicitly exclude it — it's the single biggest source of bloat
due to ADF encoding.

### Use --json with jq for surgical extraction

When you need structured data from verbose responses, pipe through jq:

```bash
# Get just the summary and status as plain text
acli jira workitem view KEY-123 --json | jq '{key: .key, summary: .fields.summary, status: .fields.status.name}'

# Extract comment bodies from a work item
acli jira workitem view KEY-123 --fields "comment" --json | jq '[.fields.comment.comments[] | {author: .author.displayName, body: .body}]'

# Get a compact list from search results
acli jira workitem search --jql "assignee = currentUser()" --json | jq '[.[] | {key: .key, summary: .fields.summary, status: .fields.status.name}]'
```

### Use --csv for tabular summaries

For search results you just need to scan, `--csv` is far more compact than JSON or default output:

```bash
acli jira workitem search --jql "project = PROJ AND status != Done" --fields "key,summary,status,assignee" --csv
```

### Use --count when you only need a number

```bash
acli jira workitem search --jql "project = PROJ AND sprint in openSprints()" --count
```

### Prefer search over view for bulk lookups

Rather than calling `workitem view` in a loop (each returning the full payload), use a single
`workitem search` with a JQL `key in (KEY-1, KEY-2, KEY-3)` query and `--fields` to get exactly
what you need in one call.

### ADF description handling

Jira descriptions are stored in Atlassian Document Format — a deeply nested JSON tree, not plain
text or markdown. When the user asks about a work item's description, either:

1. Exclude it with `--fields "-description"` and tell the user to check the web UI, or
2. Fetch it and extract the text content nodes from the ADF with jq, e.g.:

```bash
acli jira workitem view KEY-123 --fields "description" --json | jq '[recurse(.content[]?) | select(.type == "text") | .text] | join("")'
```

### Status categories

Jira statuses (e.g. "In Review", "Code Review") map to three built-in status categories:
**To Do**, **In Progress**, and **Done**. When filtering by status in JQL, use the exact status
name (e.g. `status = "In Review"`), or use `statusCategory` for broader matching
(e.g. `statusCategory = "In Progress"` catches all active statuses).

## Best Practices

1. **Filter output aggressively** - Always use `--fields`, `--json | jq`, or `--csv` to minimize token usage
2. **Use JQL for searches** - JQL (Jira Query Language) provides powerful search capabilities
3. **Discover options with --help** - Commands have many flags and options; always check help when unsure
4. **Use output format flags** - Most commands support `--json` and `--csv` for structured output
5. **Use --paginate for large result sets** - Avoids missing results due to default limits
6. **Present clean output** - Parse command output to present relevant information to the user
7. **Verify permissions** - Some operations require specific Jira/Confluence permissions

## Error Handling

If commands fail with authentication errors:

- Check authentication status with `acli auth status` or `acli jira auth status`
- Authenticate using the appropriate method:
  - For OAuth: `acli auth login` or `acli jira auth login --web`
  - For API token: `acli jira auth login --site "site" --email "email" --token`
- If OAuth is not available in the organization, use API token authentication

For other errors:

- **Permission errors**: Explain that the user may not have necessary permissions
- **Not found errors**: Verify work item keys, project keys, or IDs are correct

## Additional Features

- **Rovo Dev**: AI coding agent (beta) - `acli rovodev -h`
- **Feedback**: Submit feedback or report issues - `acli feedback`
- **Configuration**: Change settings - `acli config -h`

## Notes

- acli works with Atlassian Cloud products
- Most list/search commands support `--json` and `--csv` output flags
- Work items were formerly called "issues" in Jira
- Some commands may require specific subscription levels or permissions
- Global OAuth (`acli auth login`) may not be available in all organizations
- Product-specific authentication (`acli jira auth login`) supports both OAuth and API tokens
- Bulk operations on multiple work items use `--key "KEY-1,KEY-2"` or `--jql` or `--filter` flags
- Use `--yes` flag to skip confirmation prompts for destructive/bulk operations
