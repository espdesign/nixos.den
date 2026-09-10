# abberath is a HP OMEN 25L gaming/workstation (intel, nvidia turing)
{
  inputs,
  den,
  lib,
  ...
}:
{
  den.aspects.abberath = {
    includes = [
      den.provides.hostname

    ];
    provides.to-users.includes = [
      den.aspects.gui
      den.aspects.gnome
      den.aspects.cli
      den.aspects.scripts
      den.aspects.pipewire-sound
      den.aspects.vm
      den.aspects.cups-print
      den.aspects.fonts
      den.aspects.virt-manager

      #specific to gaming desktop
      den.aspects.gaming
      den.aspects.nvidia

    ];
    nixos =
      { pkgs, ... }:
      {
        imports = [ ../_nixos/abberath-omen.nix ];
        environment.systemPackages = with pkgs; [ ];
      };
  };
}
