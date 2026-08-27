{ den, ... }:
{
  den.aspects.hyprland.provides.swayosd =
    { user, host, ... }:
    {
      homeManager =
        { pkgs, ... }:
        {
          # SwayOSD provides popups for volume, mute, brightness, and media player controls
          home.packages = with pkgs; [
            swayosd
          ];

          # Monokai Pro styled OSD popup theme
          xdg.configFile."swayosd/style.css".text = ''
            window#osd {
              border-radius: 16px;
              border: 2px solid #ffd866;
              background: rgba(45, 42, 46, 0.92);
              box-shadow: 0px 4px 12px rgba(0, 0, 0, 0.5);
            }
            window#osd #container {
              margin: 16px;
            }
            window#osd image,
            window#osd label {
              color: #fcfcfa;
            }
            window#osd progressbar:disabled,
            window#osd image:disabled {
              opacity: 0.5;
            }
            window#osd progressbar,
            window#osd segmentedprogress {
              min-height: 8px;
              border-radius: 999px;
              background: transparent;
              border: none;
            }
            window#osd trough,
            window#osd segment {
              min-height: inherit;
              border-radius: inherit;
              border: none;
              background: rgba(114, 112, 114, 0.4);
            }
            window#osd progress,
            window#osd segment.active {
              min-height: inherit;
              border-radius: inherit;
              border: none;
              background: #ff6188;
            }
            window#osd segment {
              margin-left: 8px;
            }
            window#osd segment:first-child {
              margin-left: 0;
            }
          '';
        };
    };
}
