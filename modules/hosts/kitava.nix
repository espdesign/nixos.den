{
  inputs,
  den,
  lib,
  ...
}:
{
  den.aspects.kitava = {
    includes = [
      den.provides.hostname
      den.aspects.gnome
    ];
    nixos =
      { pkgs, ... }:
      {
        imports = [ ../_nixos/kitava-desktop.nix ];
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
