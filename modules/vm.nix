{
  inputs,
  lib,
  config,
  den,
  ...
}:
{
  # This module consolidates all VM testing logic into a single feature.
  # It includes:
  # 1. Flake packages for running VMs (nix run .#vm)
  # 2. 'vm' aspect for global VM hardware tweaks
  # 3. 'autologin-vm' aspect for user-specific VM autologin

  # --- 1. VM Runner Packages ---
  flake.packages.x86_64-linux =
    let
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      hosts = config.flake.nixosConfigurations;
      mkVm =
        name: host:
        pkgs.writeShellApplication {
          name = "vm-${name}";
          text = ''
            ${host.config.system.build.vm}/bin/run-${host.config.networking.hostName}-vm "$@"
          '';
        };
    in
    (lib.mapAttrs' (name: host: lib.nameValuePair "vm-${name}" (mkVm name host)) hosts)
    // {
      vm = mkVm "kitava" hosts.kitava;
    };

  # --- 2. VM Hardware Tweaks Aspect ---
  den.aspects.vm = {
    nixos.virtualisation.vmVariant = {
      virtualisation.memorySize = 2048;
      virtualisation.cores = 2;
    };
  };

  # --- 3. VM Autologin Aspect (Parametric) ---
  den.aspects.autologin-vm =
    { user, ... }:
    {
      nixos =
        { config, lib, ... }:
        {
          virtualisation.vmVariant = lib.mkIf config.services.displayManager.enable {
            services.displayManager.autoLogin.enable = true;
            services.displayManager.autoLogin.user = user.userName;
          };
        };
    };

  # --- 4. TTY Autologin Provide (Parametric) ---
  den.provides.tty-autologin = userName: {
    nixos =
      { pkgs, lib, ... }:
      {
        systemd.services."getty@tty1".enable = false;
        systemd.services."autologin@tty1" = {
          description = "Autologin on tty1";
          wantedBy = [ "multi-user.target" ];
          after = [ "getty.target" ];
          serviceConfig = {
            Type = "idle";
            ExecStart = "${lib.getBin pkgs.systemd}/bin/agetty --autologin ${userName} --noclear tty1 linux";
            Restart = "always";
            StandardInput = "tty";
            StandardOutput = "tty";
          };
        };
      };
  };
}
