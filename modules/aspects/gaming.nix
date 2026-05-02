{ den, ... }:
{
  den.aspects.gaming = {
    includes = [
      (den.provides.unfree [
        "nvidia-x11"
        "nvidia-settings"
        "steam"
        "steam-original"
        "steam-run"
      ])
    ];

    nixos =
      { config, pkgs, ... }:
      {
        # --- Nvidia configuration ---
        hardware.graphics = {
          enable = true;
          enable32Bit = true;
        };

        services.xserver.videoDrivers = [ "nvidia" ];

        hardware.nvidia = {
          modesetting.enable = true;
          powerManagement.enable = true;
          powerManagement.finegrained = false;
          open = true;
          nvidiaSettings = true;
          package = config.boot.kernelPackages.nvidiaPackages.stable;
        };

        # --- Steam configuration ---
        programs.steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          localNetworkGameTransfers.openFirewall = true;
        };

        # --- GameMode ---
        programs.gamemode.enable = true;

        # --- Useful packages for gaming ---
        environment.systemPackages = with pkgs; [
          protonup-qt
          mangohud
        ];
      };
  };
}
