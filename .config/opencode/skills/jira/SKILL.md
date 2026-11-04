# Jira Skill

Guidelines for creating and managing Jira issues for HashiCorp projects.

## InfraGraph Project (IG)

### Project Information

- **Project Key**: `IG`
- **Team Field**: `customfield_10001`
- **Default Team Value**: `"InfraGraph-Graph Engine"`

### Creating Issues

When creating Jira issues for the InfraGraph project, always include the team field:

```python
jira_create_issue(
    project_key="IG",
    summary="Task summary",
    issue_type="Task",
    description="Task description",
    additional_fields={
        "customfield_10001": {"value": "InfraGraph-Graph Engine"}
    }
)
```

### Linking to Epics

When creating issues under an epic, use the `parent` field in `additional_fields`. This automatically inherits the team field from the parent epic:

```python
jira_create_issue(
    project_key="IG",
    summary="Subtask summary",
    issue_type="Task",
    description="Task description",
    additional_fields={
        "parent": "IG-1234"
    }
)
```

**Note**: When linking to an epic via `parent`, you don't need to explicitly set `customfield_10001` as it will be inherited.

### Common Issue Types

- **Epic**: Large features that need to be broken down
- **Task**: Standard work items
- **Story**: User-facing features
- **Bug**: Defects or issues
- **Subtask**: Use `parent` field to link to parent issue

### Best Practices

1. Always check the parent epic's team field when creating child issues
2. Use descriptive summaries that clearly state the objective
3. Include clear success criteria in the description
4. Link related issues appropriately
5. Set appropriate priority and labels when creating issues
