{ den, ... }:
{
  den.aspects.gaming = {
    includes = [
      (den.provides.unfree [
        "nvidia-x11"
        "nvidia-settings"
        "steam"
        "steam-unwrapped"
      ])
      # Include Path of Building sub-aspect by default
      den.aspects.gaming.provides.pob
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
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          protonup-qt
          mangohud
        ];
      };
  };
}
