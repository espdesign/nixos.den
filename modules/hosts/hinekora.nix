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

    ];
    provides.to-users.includes = [
      den.aspects.syncthing
      den.aspects.gui
      den.aspects.dev
      den.aspects.pob
      den.aspects.gnome
      den.aspects.scripts
      den.aspects.pipewire-sound
      den.aspects.vm
      den.aspects.cups-print
      den.aspects.fonts
      den.aspects.virt-manager
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
