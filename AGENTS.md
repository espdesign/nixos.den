# AI Agent Instructions

- **Nix Flakes & Untracked Files:** Whenever you create a new file, you MUST stage it using `git add <file>` or `git add .` before running commands like `nix flake check`, `nixos-rebuild`, or `nix run`. Nix flakes do not recognize untracked files, which will result in "attribute missing" or "no such file or directory" errors.
