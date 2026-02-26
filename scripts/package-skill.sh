#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$ROOT_DIR/dist"
mkdir -p "$OUT_DIR"

VERSION="0.1.0"
ARCHIVE="$OUT_DIR/atlassian-jira-skill-${VERSION}.tar.gz"

tar -C "$ROOT_DIR/.." -czf "$ARCHIVE" atlassian-jira

echo "$ARCHIVE"
