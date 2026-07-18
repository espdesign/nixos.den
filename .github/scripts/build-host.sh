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

if nix build "$attr" --no-link --option warn-dirty false > "$log_file" 2>&1; then
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

# Print warnings and traces in their raw form to the console so problem matchers can annotate them
if grep -q -i -E "(warning|trace|evaluation warning|error):" "$log_file"; then
  echo "--- Build Warnings & Traces ---"
  grep -i -E "(warning|trace|evaluation warning|error):" "$log_file" || true
  echo "-------------------------------"
fi

# Tail the last lines and strip backticks to prevent breaking markdown
log_content="$(tail -n "$max_lines" "$log_file" | sed 's/`//g')"

# Ensure the log content size doesn't exceed a safe threshold for the PR body (e.g. 15,000 characters)
if [ ${#log_content} -gt 15000 ]; then
  log_content="... (truncated to fit PR body limit) ...
${log_content: -15000}"
fi

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  delimiter="EOF_$(date +%s)_${host}"
  {
    echo "log<<${delimiter}"
    echo "$log_content"
    echo "${delimiter}"
  } >> "$GITHUB_OUTPUT"
else
  echo "--- Sanitized Log Tail ---"
  echo "$log_content"
fi

rm -f "$log_file"
