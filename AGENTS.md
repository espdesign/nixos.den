# AI Agent Instructions

## Debugging

[Use /den-debugging skill](.agents/skills/den-debugging/SKILL.md)

## Repo Rules

### Nix Flakes & Untracked Files

Stage new files with `git add <file>` before running `nix flake check`, `nixos-rebuild`, or `nix run`. Nix flakes ignore untracked files, causing "attribute missing" errors.

### Aspect Functions & `builtins.functionArgs`

Den uses `builtins.functionArgs` to detect whether an aspect function is parametric (receives context) or static. A function `{ ... }:` returns `{}` from `functionArgs`, causing Den to treat it as static and **never call it with context**.

Use explicit destructuring to receive context:

- **CORRECT:** `{ user, host, ... }:` or `{ user, ... }:` → `functionArgs` shows expected args → Den calls it with context
- **WRONG:** `{ ... }:` → `functionArgs` returns `{}` → Den skips it silently

This applies to aspects listed in `provides.to-users.includes` and likely other pipeline contexts.
