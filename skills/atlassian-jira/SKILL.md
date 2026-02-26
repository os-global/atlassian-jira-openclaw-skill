---
name: atlassian-jira
description: Jira-focused Atlassian CLI (acli) workflows for auth, search, create/update, transitions, comments, and automation-safe output handling.
version: 0.1.0
---

# Atlassian Jira (acli)

Use this skill to work with **Jira Cloud** from the terminal using Atlassian CLI (`acli`).

> Scope: Jira flows only (no Confluence/admin workflows in this skill).

## Required environment variables

Set these before using commands:

- `JIRA_URL` - Jira site host, e.g. `your-site.atlassian.net`
- `JIRA_EMAIL` - Atlassian account email
- `JIRA_API_TOKEN` - Atlassian API token

## Install `acli` on Linux

Preferred (binary install; works in local and CI/container contexts):

```bash
# arm64
curl -fsSL -o acli "https://acli.atlassian.com/linux/latest/acli_linux_arm64/acli"
# amd64
# curl -fsSL -o acli "https://acli.atlassian.com/linux/latest/acli_linux_amd64/acli"
chmod +x ./acli
sudo install -o root -g root -m 0755 ./acli /usr/local/bin/acli
acli --help
```

Alternative package-manager install is available in Atlassian docs.

## Non-interactive authentication

```bash
printf '%s' "$JIRA_API_TOKEN" | acli jira auth login \
  --site "$JIRA_URL" \
  --email "$JIRA_EMAIL" \
  --token
```

Use this pattern for CI and containers (no browser prompts).

## Practical Jira command patterns

### Health / quick checks

```bash
acli jira workitem search --jql 'order by updated DESC' --limit 5
acli jira project list --limit 20
```

### Search and get details

```bash
acli jira workitem search --jql 'project = APP AND statusCategory != Done ORDER BY priority DESC' --limit 25
acli jira workitem view APP-123
acli jira workitem view APP-123 --json | jq '.fields.summary'
```

### Create and edit

```bash
acli jira workitem create \
  --project APP \
  --type Task \
  --summary 'Investigate login timeout' \
  --description 'User sessions expire earlier than expected.'

acli jira workitem edit APP-123 --summary 'Investigate login timeout (high priority)'
acli jira workitem edit APP-123 --description 'Updated repro steps and impact assessment.'
```

### Assignment and transitions

```bash
acli jira workitem assign APP-123 --assignee "alice@example.com"
acli jira workitem transition APP-123 --status "In Progress"
acli jira workitem transition APP-123 --status "Done"
```

### Comments

```bash
acli jira workitem comment add APP-123 --text 'Root cause identified; fix in review.'
acli jira workitem comment list APP-123
```

### Bulk / repeatable operations

```bash
acli jira workitem search --jql 'project = APP AND labels = stale' --limit 50 --json > stale-items.json
jq -r '.[].key' stale-items.json | while read -r issue; do
  acli jira workitem comment add "$issue" --text 'Auto-note: stale triage review scheduled.'
done
```

## Safe command chaining and output redirection

Use standard shell operators deliberately:

- `&&` run next command only when previous succeeds.
- `>` overwrite file output; prefer writing to dedicated temp/work files.
- `|` pipe output into filters (`grep`, `jq`, etc.).

Examples:

```bash
acli jira workitem search --jql 'project = APP' --limit 10 && echo 'Search ok'
acli jira workitem search --jql 'project = APP' --limit 100 --csv > app-workitems.csv
acli jira workitem view APP-123 --json | jq '{key: .key, summary: .fields.summary, status: .fields.status.name}'
```

Safety guidance:

- Avoid destructive commands (delete/archive) in blind pipelines.
- Preview targets first (`search`/`view`) before mutating.
- Prefer `--json` + `jq` for deterministic parsing over text scraping.
- Keep generated files under explicit paths (e.g., `./out/`) and commit only intentional artifacts.

## CI strategy

- Install `acli` in the job using binary download.
- Inject `JIRA_URL`, `JIRA_EMAIL`, `JIRA_API_TOKEN` via CI secret variables.
- Authenticate by piping token to `acli jira auth login --token`.
- Run idempotent reads first; gate write operations behind branch/manual approvals when needed.

## Container strategy (Docker/runtime)

Use a small base image, install `acli` binary, and authenticate at runtime from env vars.

```Dockerfile
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl jq \
  && rm -rf /var/lib/apt/lists/*
ARG ACLI_ARCH=arm64
RUN curl -fsSL -o /usr/local/bin/acli "https://acli.atlassian.com/linux/latest/acli_linux_${ACLI_ARCH}/acli" \
  && chmod +x /usr/local/bin/acli
COPY scripts/container-entrypoint.sh /usr/local/bin/container-entrypoint.sh
RUN chmod +x /usr/local/bin/container-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/container-entrypoint.sh"]
```

Runtime example:

```bash
docker run --rm \
  -e JIRA_URL \
  -e JIRA_EMAIL \
  -e JIRA_API_TOKEN \
  ghcr.io/OWNER/atlassian-jira-skill:latest \
  acli jira workitem search --jql 'project = APP ORDER BY updated DESC' --limit 10
```

`container-entrypoint.sh` should:
1) validate env vars,
2) run non-interactive login,
3) exec passed command.

## References

- Atlassian CLI introduction: https://developer.atlassian.com/cloud/acli/guides/introduction/
- Install on Linux: https://developer.atlassian.com/cloud/acli/guides/install-linux/
- Command reference: https://developer.atlassian.com/cloud/acli/reference/commands/
- Use ACLI in CI: https://developer.atlassian.com/cloud/acli/guides/use-acli-on-ci/
- Chaining/output redirection: https://developer.atlassian.com/cloud/acli/guides/manage-command-chaining-and-output-redirection/
