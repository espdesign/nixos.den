#!/usr/bin/env bash
set -euo pipefail

WARNINGS_DIR="${1:-/tmp/warnings}"
BODY="Automated flake.lock update."

if [ -d "$WARNINGS_DIR" ]; then
  SECTIONS=""
  for f in "$WARNINGS_DIR"/warnings-*.txt; do
    [ -f "$f" ] && [ -s "$f" ] || continue
    HOST=$(basename "$f" .txt | sed 's/^warnings-//')
    SECTIONS="$SECTIONS### $HOST"$'\n'"\`\`\`"$'\n'"$(cat "$f")"$'\n'"\`\`\`"$'\n'
  done
  if [ -n "$SECTIONS" ]; then
    BODY="$BODY"$'\n\n'"## Eval Warnings"$'\n\n'"$SECTIONS"
  fi
fi

echo "$BODY"
