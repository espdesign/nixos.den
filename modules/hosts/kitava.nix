{ inputs, den, lib, ... }: {
  den.aspects.kitava = { # (6)
    includes = [ den.provides.hostname ];
    nixos = { pkgs, ... }: {
      imports = [ ../_nixos/kitava-desktop.nix ];
      environment.systemPackages = with pkgs; [ firefox vscodium git gh opencode];
      nix.settings.experimental-features = ["nix-command" "flakes"];
    };
  };
}