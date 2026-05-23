#!/usr/bin/env bash
set -euo pipefail

host="$1"
attr="$2"
max_lines="$3"

if [ -z "$attr" ]; then
  attr=".#nixosConfigurations.${host}.config.system.build.toplevel"
fi

echo "Building ${host} (${attr})..."
log_file="$(mktemp)"

if nix build "$attr" --no-link > "$log_file" 2>&1; then
  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "status=success" >> "$GITHUB_OUTPUT"
  else
    echo "status=success"
  fi
else
  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "status=failure" >> "$GITHUB_OUTPUT"
  else
    echo "status=failure"
  fi
  echo "--- Build failed ---"
  cat "$log_file"
  echo "--- End build log ---"
fi

# Tail the last lines, strip backticks, and highlight warnings
log_content="$(tail -n "$max_lines" "$log_file" | sed 's/`//g' | sed -E 's/^([[:space:]]*(warning|trace|evaluation warning):)/⚠️ \1/I')"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  delimiter="EOF_$(date +%s)_${host}"
  {
    echo "log<<${delimiter}"
    echo "$log_content"
    echo "${delimiter}"
  } >> "$GITHUB_OUTPUT"
else
  echo "--- Sanitized Log ---"
  echo "$log_content"
fi

rm -f "$log_file"
