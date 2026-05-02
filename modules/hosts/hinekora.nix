{
  inputs,
  den,
  lib,
  ...
}:
{
  den.aspects.hinekora = {
    includes = [
      den.provides.hostname
      den.aspects.gnome
    ];
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
          gemini-cli
          nil
        ];
        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
  };
}
