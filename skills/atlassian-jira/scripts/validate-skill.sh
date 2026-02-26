#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

required=(
  "$ROOT_DIR/SKILL.md"
  "$ROOT_DIR/references/jira-command-patterns.md"
  "$ROOT_DIR/scripts/container-entrypoint.sh"
)

for f in "${required[@]}"; do
  [[ -f "$f" ]] || { echo "Missing required file: $f"; exit 1; }
done

grep -q 'JIRA_API_TOKEN' "$ROOT_DIR/SKILL.md"
grep -q 'JIRA_URL' "$ROOT_DIR/SKILL.md"
grep -q 'JIRA_EMAIL' "$ROOT_DIR/SKILL.md"
grep -q 'acli jira workitem' "$ROOT_DIR/SKILL.md"

echo "Skill structure validation passed: $ROOT_DIR"
