{ den, ... }:
{
  den.aspects.gnome = {
    nixos = {
      # Enable the GNOME Desktop Environment.
      services.displayManager.gdm.enable = true;
      services.desktopManager.gnome.enable = true;

      # Configure keymap in X11
      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };

      # Automatically configure GNOME settings for all Home Manager users 
      # on hosts where GNOME is enabled.
      home-manager.sharedModules = [
        ({ config, ... }: {
          # Configure GNOME Settings
          dconf = {
            enable = true;
            settings = {
              "org/gnome/shell" = {
                disable-user-extensions = false;
                # Enable the app indicator extension (tray icons)
                enabled-extensions = [ "appindicatorsupport@rgcjonas.gmail.com" ];
                favorite-apps = [
                  "org.gnome.Nautilus.desktop"
                  "firefox.desktop"
                  "com.mitchellh.ghostty.desktop"
                ];
              };

              "org/gnome/desktop/interface" = {
                show-battery-percentage = true;
                clock-format = "12h";
                color-scheme = "prefer-dark";
              };

              # Set desktop background for dark and light mode directly from the Nix store
              "org/gnome/desktop/background" = {
                picture-uri = "file://${../wallpaper-molly.jpg}";
                picture-uri-dark = "file://${../wallpaper-molly.jpg}";
              };
            };
          };
        })
      ];
    };
  };
}
