#!/usr/bin/env bash
set -euo pipefail

: "${JIRA_URL:?JIRA_URL is required}"
: "${JIRA_EMAIL:?JIRA_EMAIL is required}"
: "${JIRA_API_TOKEN:?JIRA_API_TOKEN is required}"

printf '%s' "$JIRA_API_TOKEN" | acli jira auth login \
  --site "$JIRA_URL" \
  --email "$JIRA_EMAIL" \
  --token >/dev/null

exec "$@"
