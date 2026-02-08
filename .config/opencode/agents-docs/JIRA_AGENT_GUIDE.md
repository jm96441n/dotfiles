# Jira Agent Quick Reference Guide

## 🚀 Getting Started

Your Jira agent is now configured and ready to use!

### How to Use

1. **Launch OpenCode** in your terminal:
   ```bash
   opencode
   ```

2. **Switch to Jira mode** by pressing `Tab` until you see "Mode: jira" in the corner
   - Press `Tab` to cycle through: Build → Plan → Jira

3. **Start using natural language** to interact with Jira:
   ```
   show me all my open bugs
   create a task for fixing the login issue
   what's in the current sprint?
   ```

## 📋 Common Commands

### Personal Queries
```
show me my open issues
what bugs are assigned to me?
issues I reported this week
my high priority tasks
```

### Search & Discovery
```
find all bugs created this week
show me high priority stories in PROJECT-X
what issues are blocking PROJ-123?
find all epics without subtasks
unassigned bugs in the current sprint
```

### Creating Issues
```
create a bug for the login page crash
create an epic called "User Authentication"
create 5 subtasks for PROJ-123
create issues from my TODO.md file
```

### Managing Issues
```
move PROJ-123 to in progress
assign PROJ-456 to me
update PROJ-789 priority to high
add comment to PROJ-100 about the fix
link PROJ-123 to PROJ-456 as blocks
```

### Sprint Management
```
show me the current sprint
what's in sprint 15?
create a new sprint starting next Monday
add PROJ-123 to the active sprint
move incomplete issues to next sprint
```

### Bulk Operations
```
create 10 tasks from this list: [...]
update all bugs in epic PROJ-100 to priority high
show me changelog for all issues in sprint 10
close all issues with label "duplicate"
```

### Analysis & Reporting
```
show me issues blocking PROJ-100
what's the status of epic PROJ-50?
find all issues updated by john@example.com this month
which issues have no assignee?
show me board status for project MYPROJ
```

## 🎯 Features

### ✅ Natural Language Processing
- Talk to Jira naturally - no need to learn JQL syntax
- The agent converts your queries to proper JQL automatically

### ✅ Interactive Workflows
- Guided prompts for complex operations
- Step-by-step issue creation
- Smart suggestions for next actions

### ✅ Intelligent Suggestions
- Status transition recommendations
- Link related issues automatically
- Sprint planning guidance
- Epic management tips

### ✅ Bulk Operations
- Create multiple issues at once
- Update many issues efficiently
- Batch query with pagination

### ✅ Local Context Integration
- Read task lists from local files
- Create issues from TODO.md or notes.md
- Reference design documents

### ✅ Git Integration
- Check commit history
- Link commits to issues
- Search for issue references in git log

## 🔧 Configuration

Your Jira agent is configured at:
```
~/.config/opencode/agents/jira.md
```

### Default Settings
- **Mode**: Primary agent (use Tab to switch)
- **Temperature**: 0.2 (focused and deterministic)
- **Tools**: All Jira MCP tools enabled
- **File Operations**: Read-only (can't modify local files)
- **Bash**: Limited permissions (ask for approval)

### Customization
You can edit the agent file to:
- Change the temperature for more creative responses
- Adjust tool permissions
- Modify the system prompt
- Add project-specific instructions

## 💡 Pro Tips

### 1. Project Context
When working with a specific project, mention it once:
```
I'm working on project MYPROJ
show me open bugs
create a task
```
The agent will remember the project context.

### 2. Using Local Files
Create issues from task lists:
```
create issues from my tasks.md file
```

Reference design docs:
```
update PROJ-123 description with content from design.md
```

### 3. Sprint Planning
Efficient sprint workflow:
```
show me the current sprint
what's incomplete?
move these to next sprint: PROJ-1, PROJ-2, PROJ-3
create new sprint starting Feb 1st
```

### 4. Epic Management
Create epics with subtasks:
```
create an epic called "Mobile App Redesign"
[after creation]
create 5 stories for this epic: Home, Profile, Settings, Search, Notifications
```

### 5. Bulk Operations
Use batch operations for efficiency:
```
create 10 tasks from this list:
1. Setup project
2. Design architecture
3. Implement API
...
```

### 6. Interactive Mode
Let the agent guide you:
```
help me create a bug
[agent will ask step-by-step questions]
```

## 🔍 JQL Translation Examples

The agent automatically converts natural language to JQL:

| Natural Language | JQL Translation |
|-----------------|-----------------|
| "my open issues" | `assignee = currentUser() AND status != Closed` |
| "bugs this week" | `issuetype = Bug AND updated >= startOfWeek()` |
| "high priority stories" | `issuetype = Story AND priority = High` |
| "unassigned bugs" | `assignee is EMPTY AND issuetype = Bug` |
| "issues in epic PROJ-100" | `parent = PROJ-100 OR "Epic Link" = PROJ-100` |

## 🛠️ Troubleshooting

### Agent Not Showing Up
1. Verify the file exists: `ls ~/.config/opencode/agents/jira.md`
2. Check the frontmatter has `mode: primary`
3. Restart OpenCode

### Can't Find Issues
1. Verify you have access to the Jira project
2. Check the project key is correct
3. Use: `show me all projects` to see available projects

### Permission Errors
1. The agent will ask for permission for certain bash commands
2. Jira operations use the Jira MCP server credentials
3. Check your Jira API token is configured

### Need to Customize
Edit the agent file:
```bash
vim ~/.config/opencode/agents/jira.md
```

Change temperature, tools, or prompt as needed.

## 📚 Resources

- [OpenCode Documentation](https://opencode.ai/docs/agents/)
- [Jira MCP Server](https://github.com/modelcontextprotocol/servers) (if applicable)
- [JQL Reference](https://support.atlassian.com/jira-service-management-cloud/docs/use-advanced-search-with-jira-query-language-jql/)

## 🎉 Example Session

```bash
# Start OpenCode
$ opencode

# Press Tab until you see "Mode: jira"
<Tab>

# Now start working with Jira naturally
> show me my open bugs

[Agent shows list of bugs]

> create a subtask for PROJ-123 to fix the database connection

[Agent guides you through creation]

> what's blocking this issue?

[Agent shows blocking issues]

> move PROJ-123 to in progress and assign to me

[Agent transitions issue and confirms]

> show me the current sprint status

[Agent displays sprint overview]

# Press Tab to switch back to Build mode when done
<Tab>
```

## 🎯 Next Steps

1. Try switching to Jira mode with `Tab`
2. Start with a simple query: `show me my open issues`
3. Experiment with creating issues
4. Try bulk operations with local files
5. Explore sprint planning features

Happy Jira-ing! 🚀

---

**Need Help?**
- Ask the agent: "help me get started with Jira"
- Check OpenCode docs: https://opencode.ai/docs/
- Open an issue: https://github.com/anomalyco/opencode/issues
