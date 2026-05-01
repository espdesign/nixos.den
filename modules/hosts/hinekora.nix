{
  inputs,
  den,
  lib,
  ...
}:
{
  den.aspects.hinekora = {
    # (6)
    includes = [ den.provides.hostname ]; # (7)/home/espdesign/git/nixos.config/hosts/kitava-desktop/hardware.nix
    nixos =
      { pkgs, ... }:
      {
        imports = [ ../_nixos/hinekora-framework.nix ]; # (8)
        environment.systemPackages = with pkgs; [
          firefox
          vscodium
          git
          gh
          opencode
        ];
        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
  };
}
