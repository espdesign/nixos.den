# AI Agent Instructions

- **Nix Flakes & Untracked Files:** Whenever you create a new file, you MUST stage it using `git add <file>` or `git add .` before running commands like `nix flake check`, `nixos-rebuild`, or `nix run`. Nix flakes do not recognize untracked files, which will result in "attribute missing" or "no such file or directory" errors.

- **Aspect Functions & `builtins.functionArgs`:** Den uses `builtins.functionArgs` to detect whether an aspect function is parametric (receives context) or static. An aspect function `{ ... }:` returns `{}` from `functionArgs`, causing Den to treat it as static and **never call it with context**. To be properly evaluated, use an explicit destructuring pattern like `{ user, host, ... }:` or `{ user, ... }:`. This applies to aspects listed in `provides.to-users.includes` and likely other pipeline contexts.
  - CORRECT: `{ user, host, ... }:` or `{ user, ... }:` → `functionArgs` shows expected args → Den calls it with context
  - WRONG: `{ ... }:` → `functionArgs` returns `{}` → Den skips it silently

- [Denful/Den Docs](https://github.com/denful/den/tree/main/docs/src/content/docs)
