{ den, ... }:
{
  den.aspects.nvidia = {
    includes = [
      (den.provides.unfree [
        "nvidia-x11"
        "nvidia-settings"
      ])
    ];

    nixos =
      { config, ... }:
      {
        # --- Kernel & Module Options for ReBAR ---
        boot.kernelParams = [ "nvidia.NVreg_EnableResizableBar=1" ];

        boot.extraModprobeConfig = ''
          options nvidia NVreg_EnableResizableBar=1
        '';

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
      };
  };
}
