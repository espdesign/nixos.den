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
                modules-right = [ "pulseaudio" "network" "battery" "tray" ];

                clock = {
                  format = "{:%I:%M %p - %a, %b %d}";
                };

                battery = {
                  format = "{capacity}% {icon}";
                  format-icons = [ "" "" "" "" "" ];
                };

                network = {
                  format-wifi = "{essid} 󰤨";
                  format-ethernet = "Ethernet 󰈀";
                  format-disconnected = "Disconnected 󰤮";
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
                border: 2px solid #ab9df2;
                border-radius: 12px;
                margin: 5px;
                padding: 0 8px;
              }
              #workspaces button {
                color: #727072;
                padding: 0 4px;
              }
              #workspaces button.active {
                color: #ab9df2;
              }
              #workspaces button.urgent {
                color: #ff6188;
              }

              #clock {
                background: #2d2a2e;
                border: 2px solid #ff6188;
                border-radius: 12px;
                margin: 5px;
                padding: 0 12px;
                color: #ff6188;
              }

              #pulseaudio {
                background: #2d2a2e;
                border: 2px solid #a9dc76;
                border-radius: 12px;
                margin: 5px;
                padding: 0 12px;
                color: #a9dc76;
              }

              #network {
                background: #2d2a2e;
                border: 2px solid #78dce8;
                border-radius: 12px;
                margin: 5px;
                padding: 0 12px;
                color: #78dce8;
              }

              #battery {
                background: #2d2a2e;
                border: 2px solid #fc9867;
                border-radius: 12px;
                margin: 5px;
                padding: 0 12px;
                color: #fc9867;
              }
              #battery.charging {
                color: #a9dc76;
                border-color: #a9dc76;
              }
              #battery.warning:not(.charging) {
                color: #ffd866;
                border-color: #ffd866;
              }
              #battery.critical:not(.charging) {
                color: #ff6188;
                border-color: #ff6188;
              }

              #tray {
                background: #2d2a2e;
                border: 2px solid #ffd866;
                border-radius: 12px;
                margin: 5px;
                padding: 0 12px;
              }
            '';
          };
        };
    };
}
