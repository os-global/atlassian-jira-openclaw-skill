# Jira ACLI command patterns (quick reference)

All examples assume prior auth with:

```bash
printf '%s' "$JIRA_API_TOKEN" | acli jira auth login --site "$JIRA_URL" --email "$JIRA_EMAIL" --token
```

## Read/list/search

```bash
acli jira project list --limit 50
acli jira workitem search --jql 'project = APP ORDER BY created DESC' --limit 20
acli jira workitem view APP-101
```

## Create/update

```bash
acli jira workitem create --project APP --type Bug --summary 'Checkout button disabled'
acli jira workitem edit APP-101 --summary 'Checkout button disabled on Safari'
```

## Assign/transition/comments

```bash
acli jira workitem assign APP-101 --assignee 'dev1@example.com'
acli jira workitem transition APP-101 --status 'In Progress'
acli jira workitem comment add APP-101 --text 'Investigating frontend validation path.'
```

## Output handling

```bash
acli jira workitem search --jql 'project = APP' --limit 100 --json > out/items.json
jq -r '.[].key' out/items.json
acli jira workitem search --jql 'project = APP' --limit 20 --csv > out/items.csv
```

## Safe chaining

```bash
acli jira workitem view APP-101 --json \
  | jq -e '.fields.status.name == "To Do"' \
  && acli jira workitem transition APP-101 --status 'In Progress'
```

Prefer `--json` + `jq` for automation. Avoid destructive actions in implicit loops without previewing targets.
