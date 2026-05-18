# nixos.den — Dendritic NixOS Configuration

A real NixOS config built on the [Den framework](https://den.oeiuwq.com/) using the **Dendritic pattern**: features organized as composable **aspects** rather than per-host silos.

Read the [Den docs](https://den.oeiuwq.com/) first, then browse `modules/` for examples of:

- **Aspects** — self-contained feature modules with per-class configs (`nixos`, `homeManager`, etc.)
- **Parametric dispatch** — aspects receive context `{ host, user }` and dispatch by function signature instead of `mkIf`
- **Dependency DAG** — aspects declare `includes`/`provides` relationships
- **Context pipeline** — `den.hosts` → host/user/home traversal → resolution → `nixosConfigurations`
- **Sub-aspects** — nested features under `den.aspects.<parent>.provides.<child>`
- **`den.provides` batteries** — built-in helpers like `hostname`, `unfree`, `define-user`, `user-shell`

## Structure

```
flake.nix           # Entry: evalModules + import-tree
modules/
├── default.nix     # den.default — global settings (applied everywhere)
├── den.nix         # Schema: hosts, users, classes
├── hosts/          # Machine aspects
├── _nixos/         # nixos-generate-config outputs (untouched)
├── assets/         # Static assets (wallpapers, etc.)
├── gaming/         # Gaming-related aspects (Steam, etc.)
└── *.nix           # Feature aspects
```

## Quick start

```
nix flake check
nix run .#vm
```

## Resources

- [Den docs](https://den.oeiuwq.com/) | [Source](https://github.com/vic/den)
- [Dendritic pattern](https://github.com/mightyiam/dendritic)
