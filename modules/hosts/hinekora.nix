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
      den.aspects.dms
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
        ];

        # Framework 12th Gen power management configuration
        # Swap TLP (from nixos-hardware) for power-profiles-daemon & UPower for GUI battery integration
        services.tlp.enable = lib.mkForce false;
        services.power-profiles-daemon.enable = true;
        services.upower.enable = true;

        environment.systemPackages = with pkgs; [ ];
      };
  };
}
