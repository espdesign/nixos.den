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

    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
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
