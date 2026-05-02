{ den, ... }:
{
  den.aspects.gui =
    { user, ... }:
    {
      includes = [
        (den.provides.unfree [
          "google-chrome"
          "obsidian"
          "signal-desktop"
          "slack"
          "spotify"
        ])
      ];

      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            # bottles
            dconf-editor
            firefox
            libreoffice
            mpv
            qbittorrent
            # stirling-pdf
            # thunderbird
            typst
            vesktop
            # google-chrome
            obsidian
            signal-desktop
            slack
            spotify
          ];
          programs.ghostty = {
            enable = true;

            settings = {
              theme = "dark:Gruvbox Dark,light:Gruvbox Light";
              window-decoration = "auto";
              background-opacity = 0.95;
              background-blur = true;

              # Optional: Explicitly set the font if you want
              # font-family = "JetBrainsMono Nerd Font";
            };
          };
          programs.firefox = {
            enable = true;
            configPath = ".config/mozilla/firefox";

            # If you had custom policies/profiles in your old config,
            # paste them here!
            profiles.default = {
              isDefault = true;
              name = user.userName;
              settings = {
              # Performance & UI
              "browser.startup.homepage" = "about:blank";
              "browser.uidensity" = 1; # Compact Mode
              "browser.tabs.inTitlebar" = 1;

              # Privacy / Annoyances
              "privacy.trackingprotection.enabled" = true;
              "dom.security.https_only_mode" = true;
              "browser.shell.checkDefaultBrowser" = false;
              "browser.aboutConfig.showWarning" = false;
              "extensions.pocket.enabled" = false; # Disable Pocket
              "identity.fxaccounts.enabled" = false; # Disable Firefox Sync (optional)
            };
          };
        };
      };
  };
}
