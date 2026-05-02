{ den, ... }:
{
  den.aspects.gui = {
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
          easyeffects
          firefox
          libreoffice
          mpv
          qbittorrent
          # stirling-pdf
          # thunderbird
          typst
          vesktop
          vscodium
          # google-chrome
          obsidian
          signal-desktop
          slack
          spotify
        ];
      };
  };
}
