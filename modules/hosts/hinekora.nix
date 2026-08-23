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
      den.aspects.hyprland
      den.aspects.scripts
      den.aspects.pipewire-sound
      den.aspects.vm
      den.aspects.cups-print
      den.aspects.fonts
      den.aspects.virt-manager
      den.aspects.rustdesk
    ];
    nixos =
      { pkgs, ... }:
      {
        imports = [
          ../_nixos/hinekora-framework.nix
          inputs.nixos-hardware.nixosModules.framework-12th-gen-intel
        ]; # (8)

        # nixos-hardware's framework module defaults to TLP, but it conflicts
        # with power-profiles-daemon (used by waybar for click-to-switch
        # power mode), so swap to power-profiles-daemon here.
        services.tlp.enable = lib.mkForce false;
        services.power-profiles-daemon.enable = true;

        environment.systemPackages = with pkgs; [ ];
      };
  };
}
