#!/usr/bin/env bash
set -euo pipefail

hosts="$1"
summary_file="${GITHUB_STEP_SUMMARY:-/dev/stdout}"

echo "## Build Results" >> "$summary_file"
echo "" >> "$summary_file"

for host in $(echo "$hosts" | jq -r '.[]'); do
  status_file="build-results/build-${host}/build-status.txt"
  if [ -f "$status_file" ]; then
    status=$(cat "$status_file")
  else
    status="skipped"
  fi
  icon=":white_check_mark:"
  [ "$status" != "success" ] && icon=":x:"
  echo "${icon} **${host}**: ${status}" >> "$summary_file"
done
