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

    ];
    provides.to-users.includes = [
      den.aspects.syncthing
      den.aspects.gui
      den.aspects.dev
      den.aspects.gnome
      den.aspects.scripts
      den.aspects.pipewire-sound
      den.aspects.vm
      den.aspects.cups-print
      den.aspects.fonts
      den.aspects.virt-manager
      den.aspects.rustdesk

      #specific to gaming desktop
      den.aspects.gaming
      den.aspects.nvidia

    ];
    nixos =
      { pkgs, ... }:
      {
        imports = [ ../_nixos/kitava-desktop.nix ];
        environment.systemPackages = with pkgs; [ ];
      };
  };
}
