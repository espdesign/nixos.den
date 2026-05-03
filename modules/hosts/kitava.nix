# kitava is my standard-desktop with nvidia 3070ti
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
      den.aspects.standard-desktop
    ];
    provides.to-users.includes = [
      den.aspects.standard-desktop
      den.aspects.gui
      den.aspects.dev

      den.aspects.gaming
      den.aspects.gaming.provides.nvidia

    ];
    nixos =
      { pkgs, ... }:
      {
        imports = [ ../_nixos/kitava-desktop.nix ];
        environment.systemPackages = with pkgs; [ ];
      };
  };
}
