# Project: nixos.den

## Overview
`nixos.den` is a personal NixOS configuration repository built using the **Den** framework. Den is a "dendritic" configuration system that prioritizes features (aspects) over traditional host-based modules, allowing for highly modular and reusable NixOS, Darwin, and Home Manager configurations.

## Architecture & Core Concepts

### Den Framework
- **Aspects:** The primary unit of configuration. Found in `modules/hosts/` and `modules/de/`, aspects define settings for NixOS and Home Manager. They are "functors" that can take parameters.
- **Hosts:** Defined in `modules/den.nix`. Each host (e.g., `hinekora`, `kitava`) is an instance of an aspect and can include other aspects.
- **Context System:** Den uses a context pipeline to transform high-level declarations into low-level NixOS/HM modules.

### Directory Structure
- `flake.nix`: The entry point. Uses `inputs.den.flakeModule` and `import-tree` to load the configuration.
- `modules/`:
  - `den.nix`: Main host and user declarations.
  - `default.nix`: Global default settings for NixOS and Home Manager.
  - `hosts/`: Host-specific aspect definitions (e.g., `hinekora.nix`).
  - `de/`: Desktop environment aspects (e.g., `gnome.nix`).
  - `_nixos/`: Hardware-specific configurations, typically generated via `nixos-generate-config`.
- `docs/`: Local copy of the Den framework documentation, covering principles, cookbook recipes, and API references.

## Building and Running

### Applying Configuration
To apply the configuration to the current system, use the standard NixOS flake command:

```bash
# Replace <hostname> with the desired host (e.g., hinekora, kitava)
sudo nixos-rebuild switch --flake .#<hostname>
```

### Testing in a VM
To test a host configuration in a virtual machine:

```bash
nixos-rebuild build-vm --flake .#<hostname>
./result/bin/run-<hostname>-vm
```

## Development Conventions

### Adding a New Host
1.  Define the host in `modules/den.nix` under `den.hosts.<system>.<hostname>`.
2.  Create a corresponding aspect in `modules/hosts/<hostname>.nix`.
3.  Include necessary batteries or other aspects (e.g., `den.provides.hostname`, `den.aspects.gnome`).
4.  Import hardware-specific settings in the `nixos` block of the aspect.

### Aspect Structure
Aspects should follow the Den pattern:
```nix
{ den, ... }:
{
  den.aspects.<name> = {
    includes = [ ... ];
    nixos = { config, pkgs, ... }: { ... };
    homeManager = { config, pkgs, ... }: { ... };
  };
}
```

### Documentation
Refer to the `docs/` directory for in-depth explanations of Den's advanced features like parametric aspects, context types, and batteries.
Refer to `docs/template` for implementation examples.