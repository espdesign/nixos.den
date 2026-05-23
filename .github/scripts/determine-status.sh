#!/usr/bin/env bash
set -euo pipefail

hosts="$1"
all_success=true
status_lines=""
log_lines=""

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

  # Include build log if present
  if [ -f "$log_file" ]; then
    log_content=$(cat "$log_file")
    if [ -n "$log_content" ]; then
      if grep -q -i -E "(warning|trace):" "$log_file"; then
        summary_title="⚠️ ${host} Build Log (with warnings)"
      else
        summary_title="📄 ${host} Build Log"
      fi
      log_lines=$(printf "%s\n\n<details>\n<summary>%s</summary>\n\n\`\`\`\n%s\n\`\`\`\n</details>" "$log_lines" "$summary_title" "$log_content")
    fi
  fi
done

combined_status="${status_lines}"
if [ -n "$log_lines" ]; then
  combined_status=$(printf "%s\n\n### Build Logs%s" "$status_lines" "$log_lines")
fi

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "all-success=${all_success}" >> "$GITHUB_OUTPUT"
  echo "host-status<<EOF" >> "$GITHUB_OUTPUT"
  echo "$combined_status" >> "$GITHUB_OUTPUT"
  echo "EOF" >> "$GITHUB_OUTPUT"
else
  echo "all-success=${all_success}"
  echo "host-status:"
  echo "$combined_status"
fi
