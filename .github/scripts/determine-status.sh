#!/usr/bin/env bash
set -euo pipefail

hosts="$1"
all_success=true
status_lines=""

for host in $(echo "$hosts" | jq -r '.[]'); do
  status_file="build-results/build-${host}/build-status.txt"
  log_file="build-results/build-${host}/build-log.txt"
  
  if [ -f "$status_file" ]; then
    status=$(cat "$status_file")
  else
    status="skipped"
  fi

  if [ "$status" != "success" ]; then
    all_success=false
  fi

  status_lines=$(printf "%s\n- **%s**: %s" "$status_lines" "$host" "$status")

  # Extract evaluation/other warnings if present in log
  if [ -f "$log_file" ]; then
    warnings=$(grep -i -E "^\s*(warning|trace):" "$log_file" || true)
    if [ -n "$warnings" ]; then
      status_lines=$(printf "%s\n  <details>\n  <summary>⚠️ Evaluation Warnings</summary>\n\n  \`\`\`\n%s\n  \`\`\`\n  </details>" "$status_lines" "$warnings")
    fi
  fi
done

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "all-success=${all_success}" >> "$GITHUB_OUTPUT"
  echo "host-status<<EOF" >> "$GITHUB_OUTPUT"
  echo "$status_lines" >> "$GITHUB_OUTPUT"
  echo "EOF" >> "$GITHUB_OUTPUT"
else
  echo "all-success=${all_success}"
  echo "host-status:"
  echo "$status_lines"
fi
