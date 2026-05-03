# hinekora is a framework 12th gen intel
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
      den.aspects.standard-desktop
    ];
    provides.to-users.includes = [
      den.aspects.standard-desktop
      den.aspects.gui
      den.aspects.dev
      den.aspects.gaming.provides.pob
    ];
    nixos =
      { pkgs, ... }:
      {
        imports = [
          ../_nixos/hinekora-framework.nix
          inputs.nixos-hardware.nixosModules.framework-12th-gen-intel
        ]; # (8)

        environment.systemPackages = with pkgs; [ ];
      };
  };
}
