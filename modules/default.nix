# den.default is a special aspect that automatically applies its configuration to every
# host, user, and home in your Den setup, making it ideal for global settings.

{ den, ... }:
{
  den.default = {
    # Set desired DE aspect.
    includes = [
      den.aspects.nix-helpers
      den.aspects.ssh
    ];
    homeManager.home.stateVersion = "25.11";
    nixos = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      system.stateVersion = "24.11"; # Did you read the comment?
      # Bootloader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      # Enable networking
      networking.networkmanager.enable = true;

      # Set your time zone.
      time.timeZone = "America/New_York";

      # Select internationalisation properties.
      i18n.defaultLocale = "en_US.UTF-8";

      i18n.extraLocaleSettings = {
        LC_ADDRESS = "en_US.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "en_US.UTF-8";
        LC_MONETARY = "en_US.UTF-8";
        LC_NAME = "en_US.UTF-8";
        LC_NUMERIC = "en_US.UTF-8";
        LC_PAPER = "en_US.UTF-8";
        LC_TELEPHONE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";
      };

      # # Enable the X11 windowing system.
      # services.xserver.enable = true;

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
}
