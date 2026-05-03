{ den, ... }:
{
  den.aspects.gnome = {
    nixos =
      { pkgs, ... }:
      {
        # Enable the GNOME Desktop Environment.
        services.displayManager.gdm.enable = true;
        services.desktopManager.gnome.enable = true;

        # Configure keymap in X11
        services.xserver.xkb = {
          layout = "us";
          variant = "";
        };
        # Exclude default GNOME bloat (Optional)
        # If you don't want Tour, Music, Epiphany, etc.
        environment.gnome.excludePackages = with pkgs; [
          gnome-tour
          gnome-music
          epiphany
        ];

        # Add GNOME specific system packages (like Tweaks)
        environment.systemPackages = with pkgs; [
          gnomeExtensions.appindicator
          dconf-editor
          gnome-shell-extensions
        ];
      };

    homeManager = {
      # Configure GNOME settings for Home Manager users.
      dconf = {
        enable = true;
        settings = {
          "org/gnome/shell" = {
            disable-user-extensions = false;
            # Enable the app indicator extension (tray icons)
            enabled-extensions = [ "appindicatorsupport@rgcjonas.gmail.com" ];

            # To find app desktop names
            # ls $(nix-build '<nixpkgs>' -A firefox)/share/applications/
            favorite-apps = [
              "org.gnome.Nautilus.desktop"
              "firefox.desktop"
              "com.mitchellh.ghostty.desktop"
              "codium.desktop"
              "steam.desktop"
              "vesktop.desktop"
            ];
          };

          "org/gnome/desktop/interface" = {
            show-battery-percentage = true;
            clock-format = "12h";
            color-scheme = "prefer-dark";
          };

          # Set desktop background for dark and light mode directly from the Nix store
          "org/gnome/desktop/background" = {
            picture-uri = "file://${./assets/wallpaper-molly.jpg}";
            picture-uri-dark = "file://${./assets/wallpaper-molly.jpg}";
          };
        };
      };
    };
  };
}
