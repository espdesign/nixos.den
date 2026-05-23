#!/usr/bin/env bash
set -euo pipefail

hosts=$(ls modules/hosts/*.nix | xargs -I{} basename {} .nix | jq -R -s -c 'split("\n") | map(select(. != ""))')

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "hosts=${hosts}" >> "$GITHUB_OUTPUT"
else
  echo "hosts=${hosts}"
fi
