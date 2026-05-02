# Den Aspect Patterns - Lessons Learned

## Problem: GNOME Not Loading After Moving to Aspect

When moving GNOME configuration from `default.nix` to a dedicated aspect in `de/gnome.nix`, the desktop environment stopped loading (system booted to TTY only).

## Root Cause

Two issues combined:
1. **Aspect format**: The `nixos` attribute in the aspect was a plain attrset instead of a function
2. **Wrong location for `includes`**: The `includes = [ den.aspects.gnome ]` was placed in `den.hosts` definition instead of the host's primary aspect

## Correct Pattern

### 1. Aspect Definition (`de/gnome.nix`)

```nix
{ ... }:
{
  den.aspects.gnome = {
    nixos = { pkgs, ... }: {
      # Enable the GNOME Desktop Environment.
      services.displayManager.gdm.enable = true;
      services.desktopManager.gnome.enable = true;

      # Configure keymap in X11
      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };
    };
  };
}
```

**Key**: `nixos` must be a function `{ pkgs, ... }: { ... }`, not a plain attrset.

### 2. Host Declaration (`den.nix`)

```nix
{
  inputs,
  den,
  lib,
  ...
}:
{
  imports = [ inputs.den.flakeModule ];

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  # Host declaration - minimal, only declare users here
  den.hosts.x86_64-linux.hinekora = { users.espdesign = { }; };
  den.hosts.x86_64-linux.kitava = { users.espdesign = { }; };
}
```

### 3. Host Primary Aspect (`hosts/hinekora.nix`)

```nix
{
  inputs,
  den,
  lib,
  ...
}:
{
  den.aspects.hinekora = {
    # includes go HERE, not in den.hosts
    includes = [
      den.provides.hostname
      den.aspects.gnome
    ];
    nixos = { pkgs, ... }: {
      imports = [ ../_nixos/hinekora-framework.nix ];
      environment.systemPackages = with pkgs; [
        firefox
        vscodium
        git
        gh
        opencode
      ];
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
    };
  };
}
```

## Key Learnings

1. **`den.default` vs aspects**: Configuration in `den.default` (in `default.nix`) applies to ALL hosts and uses standard NixOS module syntax directly.

2. **`includes` location**: The `includes` array for a host must be in the host's primary aspect (`den.aspects.<hostname>`), NOT in the `den.hosts.<system>.<name>` declaration.

3. **Aspect function format**: When defining `nixos`, `darwin`, or `homeManager` in aspects, use function form `{ pkgs, ... }: { ... }` for better compatibility with den's aspect system.

4. **`import-tree` loading**: All `.nix` files in the modules directory are loaded by `import-tree`. Test file loading by adding a syntax error - if build fails, the file is being loaded.

5. **Host declaration vs configuration**:
   - `den.hosts` in `den.nix`: Declare hosts and users only
   - `den.aspects.<hostname>` in `hosts/<name>.nix`: Configure the host (includes, nixos config, etc.)

6. **Verification command**: Use `nix eval .#nixosConfigurations.<hostname>.config.services.displayManager.gdm.enable` to verify if a service is enabled in the built config.

## Framework Laptop (hinekora) Specific Notes

- Intel-based Framework laptop
- May need `hardware.enableRedistributableFirmware = true;` for graphics firmware (not required in this case, was working before)
- Host key in `den.hosts.x86_64-linux.hinekora`

## File Structure

```
modules/
├── default.nix          # den.default - applies to all hosts
├── den.nix             # Host declarations (den.hosts)
├── espdesign.nix       # User aspect (den.aspects.espdesign)
├── de/                 # Desktop environment aspects
│   └── gnome.nix      # GNOME aspect (den.aspects.gnome)
├── hosts/              # Host-specific aspects
│   ├── hinekora.nix   # den.aspects.hinekora
│   └── kitava.nix     # den.aspects.kitava
└── _nixos/            # Hardware configurations
    ├── hinekora-framework.nix
    └── kitava-desktop.nix
```

## Build & Test Commands

```bash
# Check if GDM is enabled in built config
nix eval .#nixosConfigurations.hinekora.config.services.displayManager.gdm.enable

# Build and switch
sudo nixos-rebuild switch --flake .#hinekora

# Test if a file is being loaded (add syntax error temporarily)
echo "THIS IS A SYNTAX ERROR" >> modules/de/gnome.nix
nix eval .#nixosConfigurations.hinekora.config.services.displayManager.gdm.enable
# Should show error mentioning the file
```
