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

# Extract all warnings and traces from the entire log file to highlight and output them (handles multi-line warnings)
warnings="$(awk '
  /^[[:space:]]*(warning|trace|evaluation warning|error):/ {
    in_warning = 1
    line = $0
    gsub(/`/, "", line)
    sub(/^[[:space:]]*(warning|trace|evaluation warning|error):/, "⚠️ &", line)
    print line
    next
  }
  /^[[:space:]]*(copying path|building|these [0-9]+ derivation|fetching path|downloading|evaluating|querying)/ || /^[[:space:]]+\/nix\/store\/.*\.drv$/ {
    in_warning = 0
  }
  in_warning {
    line = $0
    gsub(/`/, "", line)
    print line
  }
' "$log_file" || true)"


# Output warnings to the console so they exist in the step's build log
if [ -n "$warnings" ]; then
  echo "--- Evaluation/Build Warnings & Traces ---"
  echo "$warnings"
  echo "------------------------------------------"
fi

# Tail the last lines, strip backticks, and highlight warnings
tail_log="$(tail -n "$max_lines" "$log_file" | sed 's/`//g' | sed -E 's/^([[:space:]]*(warning|trace|evaluation warning):)/⚠️ \1/I')"

# Prepend warnings to the captured log content if they exist
if [ -n "$warnings" ]; then
  log_content="⚠️ Evaluation/Build Warnings:
$warnings

--- Build Log Tail (last $max_lines lines) ---
$tail_log"
else
  log_content="$tail_log"
fi

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
