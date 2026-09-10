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
      den.aspects.gnome

    ];
    provides.to-users.includes = [
      den.aspects.syncthing
      den.aspects.gui-core
      den.aspects.cli
      den.aspects.docker
      den.aspects.dev
      den.aspects.pob
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
