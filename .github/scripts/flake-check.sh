#!/usr/bin/env bash
set -euo pipefail

# Run nix flake check and capture stderr
warnings_file="$(mktemp)"
trap 'rm -f "$warnings_file"' EXIT

echo "Running nix flake check..."
if nix flake check 2> "$warnings_file"; then
  cat "$warnings_file" >&2
  if grep -q "evaluation warning:" "$warnings_file"; then
    echo "::error::Evaluation warnings detected during flake check!"
    exit 1
  fi
  echo "All checks passed successfully!"
else
  rc=$?
  cat "$warnings_file" >&2
  exit "$rc"
fi
