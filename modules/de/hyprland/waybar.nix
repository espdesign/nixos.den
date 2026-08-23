{ den, ... }:
{
  den.aspects.hyprland.provides.waybar =
    { user, host, ... }:
    {
      homeManager =
        { pkgs, ... }:
        {
          programs.waybar = {
            enable = true;
            settings = {
              mainBar = {
                layer = "top";
                position = "top";
                height = 30;
                modules-left = [ "hyprland/workspaces" ];
                modules-center = [ "clock" ];
                modules-right = [ "pulseaudio" "battery" "tray" ];

                clock = {
                  format = "{:%I:%M %p - %a, %b %d}";
                };

                battery = {
                  format = "{capacity}% {icon}";
                  format-icons = [ "" "" "" "" "" ];
                };

                pulseaudio = {
                  format = "{volume}% {icon}";
                  format-muted = "󰝟";
                  format-icons = {
                    default = [ "" "" "" ];
                  };
                };
              };
            };

            # Monokai Pro Modular Block CSS styling for Waybar
            style = ''
              * {
                border: none;
                border-radius: 0;
                font-family: "JetBrainsMono Nerd Font", sans-serif;
                font-size: 12px;
                font-weight: bold;
                min-height: 0;
              }

              window#waybar {
                background: transparent;
                color: #fcfcfa;
              }

              #workspaces {
                background: #2d2a2e;
                border: 2px solid #727072;
                border-radius: 12px;
                margin: 5px;
                padding: 0 8px;
              }
              #workspaces button {
                color: #727072;
                padding: 0 4px;
              }
              #workspaces button.active {
                color: #ab9df2; /* Monokai Lavender for active workspace */
              }
              #workspaces button.urgent {
                color: #ff6188; /* Monokai Pink for urgent */
              }

              #clock {
                background: #2d2a2e;
                border: 2px solid #727072;
                border-radius: 12px;
                margin: 5px;
                padding: 0 12px;
                color: #fcfcfa;
              }

              #pulseaudio {
                background: #2d2a2e;
                border: 2px solid #727072;
                border-radius: 12px;
                margin: 5px;
                padding: 0 12px;
                color: #fcfcfa;
              }
              #pulseaudio.muted {
                color: #727072;
                border-color: #403e41;
              }

              #battery {
                background: #2d2a2e;
                border: 2px solid #727072;
                border-radius: 12px;
                margin: 5px;
                padding: 0 12px;
                color: #fcfcfa;
              }
              #battery.charging {
                color: #a9dc76; /* Monokai Green for charging */
                border-color: #a9dc76;
              }
              #battery.warning:not(.charging) {
                color: #ffd866; /* Monokai Yellow for warning */
                border-color: #ffd866;
              }
              #battery.critical:not(.charging) {
                color: #ff6188; /* Monokai Pink/Red for critical */
                border-color: #ff6188;
              }

              #tray {
                background: #2d2a2e;
                border: 2px solid #727072;
                border-radius: 12px;
                margin: 5px;
                padding: 0 12px;
              }
            '';
          };
        };
    };
}
