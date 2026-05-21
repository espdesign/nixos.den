#!/usr/bin/env bash
set -euo pipefail

# Auto-bootstrap if required packages are not in PATH
if ! command -v nixfmt &>/dev/null || ! command -v deadnix &>/dev/null || ! command -v statix &>/dev/null; then
  echo "Package dependencies missing. Re-running script inside 'nix shell'..."
  exec nix shell nixpkgs#nixfmt nixpkgs#deadnix nixpkgs#statix -c "$0" "$@"
fi


failed=0

echo "=== Running nixfmt --check ==="
# Find all .nix files excluding hidden files/directories
nix_files=$(find . -name "*.nix" -not -path "*/.*" -not -path "*_sources*")

if [ -n "$nix_files" ]; then
  if ! nixfmt --check $nix_files; then
    echo "❌ Formatting check failed! Run 'nixfmt <file>' or commit to trigger the git hook."
    failed=1
  else
    echo "✅ Formatting check passed."
  fi
else
  echo "No .nix files found to check."
fi

echo ""
echo "=== Running deadnix --fail ==="
if ! deadnix --fail -l -L .; then
  echo "❌ Unused code check failed!"
  failed=1
else
  echo "✅ Unused code check passed."
fi

echo ""
echo "=== Running statix check ==="
if ! statix check .; then
  echo "❌ Statix lint check failed!"
  failed=1
else
  echo "✅ Statix lint check passed."
fi

if [ $failed -ne 0 ]; then
  exit 1
fi

echo "🎉 All lint and formatting checks passed!"
