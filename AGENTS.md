# AI Agent Instructions

## Debugging

[Use /den-debugging skill](.agents/skills/den-debugging/SKILL.md)

## Repo Rules

### Nix Flakes & Untracked Files

Stage new files with `git add <file>` before `nix flake check`, `nixos-rebuild`, or `nix run`. Flakes ignore untracked files.

### Aspect Functions & `builtins.functionArgs`

Destructure named context args you need (e.g. `{ user, ... }:`). Never `{ ... }:` — `functionArgs` returns `{}` for that, so Den can't bind context vars.

### Aspect Granularity & Composition

Compose aspects per host/user; don't bundle optional features into shared aspects.

- No optional features in base aspects — include them explicitly per host.
- `dev` = IDE/editor tooling only. `cli`/`fonts`/`docker`/`scripts` are separate aspects.
- `gui-core` = must-have desktop apps. Preference apps (obsidian, slack, etc.) go in `modules/users/<user>.nix`.
- `den.aspects.gnome` is system-only. Per-user dconf lives in `den.aspects.gnome.provides.<user>`.
