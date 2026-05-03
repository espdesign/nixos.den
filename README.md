# nixos.den

A personal NixOS configuration repository built using the [**Den**](https://github.com/vic/den) framework. This setup leverages a **Dendritic** design pattern, prioritizing modular features (Aspects) over traditional machine-specific monoliths.

## Core Concepts

This configuration is "Feature-First." Instead of splitting logic across many directories, all system and user configurations for a single concern (like GNOME or VM testing) are consolidated into **Aspects**.

- **Aspects**: Self-contained functional modules (located in `modules/`).
- **Contexts**: Dynamic pipelines that transform your high-level declarations into NixOS and Home Manager modules.
- **Dendritic**: Logic is "functorial"—an aspect can adapt its behavior based on whether it is being applied to a Host or a User.

## Hosts

| Host | Description | Hardware |
| :--- | :--- | :--- |
| **kitava** | Main Desktop | Desktop Specs |
| **hinekora** | Framework Laptop | Framework 13" |

## Usage

### Apply Configuration
To apply the configuration to your current machine:
```bash
# Replace <hostname> with kitava or hinekora
sudo nixos-rebuild switch --flake .#<hostname>
```

### Testing in a VM
The configuration includes a custom VM runner that applies hardware overrides (2GB RAM, 2 Cores) and autologin for testing.
```bash
nix run .#vm             # Boot the default VM (kitava)
nix run .#vm-hinekora    # Boot the hinekora VM
```

### Updating
Updates are handled through standard flake commands:
```bash
nix flake update
```

## Project Structure

- `modules/den.nix`: **The Brain.** Declarations of all hosts, users, and their relationships.
- `modules/`: **The Features.** Implementation of logic (e.g., `gnome.nix`, `vm.nix`).
- `modules/hosts/`: **The Machines.** Machine-specific aspect inclusions.
- `modules/default.nix`: Global settings applied to all hosts and users.
- `modules/_nixos/`: Hardware-specific configurations (generated via `nixos-generate-config`).
- `docs/`: Local copy of the Den framework documentation.

## Development

### Adding a New Aspect
1. Create `modules/my-feature.nix`.
2. Define `den.aspects.my-feature`.
3. Include it in `modules/default.nix` (globally) or a specific host in `modules/hosts/`.

### Adding a New Host
1. Define the host in `modules/den.nix`.
2. Create a machine aspect in `modules/hosts/<hostname>.nix`.
3. Add hardware config to `modules/_nixos/`.
