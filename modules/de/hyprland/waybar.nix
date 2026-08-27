{ den, ... }:
{
  den.aspects.hyprland.provides.waybar =
    { user, host, ... }:
    {
      homeManager =
        { pkgs, ... }:
        let
          # hinekora is a 13" HiDPI panel rendered at 1x (see monitor scale in
          # default.nix), so text/UI needs to be sized up manually to stay legible.
          isHiDPI = host.hostName == "hinekora";
          fontSize = if isHiDPI then "15px" else "12px";
          barHeight = if isHiDPI then 36 else 30;

          # Waybar's built-in battery module colors purely off upower's
          # "State" property, which framework-style charge-conservation
          # thresholds can report as "Discharging" even while AC power is
          # connected (the battery is allowed to coast down within the
          # threshold band). That reads as "not plugged in" even though it
          # is, so this reads AC/battery sysfs directly and always reports
          # "charging" whenever AC is online, regardless of that hysteresis.
          batteryScript = pkgs.writeShellApplication {
            name = "waybar-battery";
            text = ''
              bat=""
              ac=""
              for d in /sys/class/power_supply/*/; do
                case "$(cat "$d/type" 2>/dev/null)" in
                  Battery) bat="$d" ;;
                  Mains) ac="$d" ;;
                esac
              done

              capacity=$(cat "''${bat}capacity")
              online=0
              if [ -n "$ac" ] && [ "$(cat "''${ac}online" 2>/dev/null)" = "1" ]; then
                online=1
              fi

              icons=("" "" "" "" "")
              idx=$(( capacity * (''${#icons[@]} - 1) / 100 ))
              icon=''${icons[$idx]}

              if [ "$online" = "1" ]; then
                bolt=$''
                printf '{"text": "%s%% %s", "class": "charging", "tooltip": "%s%% - plugged in"}\n' "$capacity" "$bolt" "$capacity"
              else
                class="discharging"
                if [ "$capacity" -le 15 ]; then
                  class="critical"
                elif [ "$capacity" -le 30 ]; then
                  class="warning"
                fi
                printf '{"text": "%s%% %s", "class": "%s", "tooltip": "%s%% - on battery"}\n' "$capacity" "$icon" "$class" "$capacity"
              fi
            '';
          };
        in
        {
          programs.waybar = {
            enable = true;
            settings = {
              mainBar = {
                layer = "top";
                position = "top";
                height = barHeight;
                modules-left = [
                  "hyprland/workspaces"
                  "hyprland/window"
                ];
                modules-center = [ "clock" ];
                modules-right = [
                  "idle_inhibitor"
                  "cpu"
                  "memory"
                  "network"
                  "bluetooth"
                  "pulseaudio"
                  "power-profiles-daemon"
                  "custom/battery"
                  "tray"
                ];

                "hyprland/workspaces" = {
                  show-special = true;
                  format = "{icon}";
                  format-icons = {
                    "1" = "1";
                    "2" = "2";
                    "3" = "3";
                    "4" = "4";
                    "5" = "5";
                    "6" = "6";
                    "7" = "7";
                    "8" = "8";
                    "9" = "9";
                    special = "󰐃";
                  };
                  on-scroll-up = "hyprctl dispatch workspace e-1";
                  on-scroll-down = "hyprctl dispatch workspace e+1";
                };

                "hyprland/window" = {
                  format = "{title}";
                  separate-outputs = true;
                  rewrite = {
                    "" = "Desktop";
                  };
                };

                clock = {
                  format = "{:%a %b %d  %I:%M %p}";
                  tooltip-format = "<tt><small>{calendar}</small></tt>";
                };

                idle_inhibitor = {
                  format = "{icon}";
                  format-icons = {
                    activated = "";
                    deactivated = "";
                  };
                  tooltip = true;
                };

                cpu = {
                  format = "CPU {usage}%";
                  tooltip = true;
                  interval = 5;
                  states = {
                    warning = 50;
                    critical = 80;
                  };
                };

                memory = {
                  format = "MEM {used:0.1f}G";
                  tooltip-format = "{used:0.1f}GB used / {total:0.1f}GB total";
                  interval = 5;
                  states = {
                    warning = 70;
                    critical = 90;
                  };
                };

                network = {
                  format-wifi = " {signalStrength}%";
                  format-ethernet = "󰈀 Wired";
                  format-linked = " {ifname} (No IP)";
                  format-disconnected = "󰤭 Offline";
                  tooltip-format = "{ifname} via {gwaddr}";
                  tooltip-format-wifi = "{essid} ({signalStrength}%) {ipaddr}/{cidr}";
                  tooltip-format-ethernet = "{ifname} {ipaddr}/{cidr}";
                  tooltip-format-disconnected = "Disconnected";
                  on-click = "nm-connection-editor";
                };

                bluetooth = {
                  format = "󰂯";
                  format-disabled = "󰂲";
                  format-off = "󰂲";
                  format-connected = "󰂱 {num_connections}";
                  tooltip-format = "{controller_alias} ({controller_address})";
                  tooltip-format-connected = "{controller_alias} ({controller_address})\n\n{device_enumerate}";
                  tooltip-format-enumerate-connected = "{device_alias}";
                  on-click = "blueman-manager";
                };

                "power-profiles-daemon" = {
                  format = "{icon}";
                  tooltip-format = "Power profile: {profile}\nDriver: {driver}";
                  format-icons = {
                    default = "";
                    performance = "";
                    balanced = "";
                    power-saver = "";
                  };
                };

                "custom/battery" = {
                  # Hides itself entirely on hosts with no battery (desktops).
                  exec-if = "ls /sys/class/power_supply/BAT* >/dev/null 2>&1";
                  exec = "${batteryScript}/bin/waybar-battery";
                  return-type = "json";
                  interval = 5;
                  tooltip = true;
                };

                pulseaudio = {
                  format = "{volume}% {icon}";
                  format-muted = "󰝟";
                  format-icons = {
                    default = [
                      ""
                      ""
                      ""
                    ];
                  };
                  on-click = "pavucontrol";
                  on-scroll-up = "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
                  on-scroll-down = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
                  # Waybar's pulseaudio module always evaluates states with "<=",
                  # never ">=" (unlike battery/cpu/etc), so a "loud" threshold would
                  # actually match every volume up to 80 and only clear once you go
                  # louder. "quiet" below flips it: <=79 is styled as normal, and
                  # anything above (80-100) falls through to the base/loud color.
                  states = {
                    quiet = 79;
                  };
                };

                tray = {
                  spacing = 10;
                };
              };
            };

            style = ''
              * {
                border: none;
                border-radius: 0;
                font-family: "JetBrainsMono Nerd Font", sans-serif;
                font-size: ${fontSize};
                font-weight: bold;
                min-height: 0;
                min-width: 0;
              }

              window#waybar {
                background-color: #2d2a2e;
                color: #fcfcfa;
                border-bottom: 1px solid #403e41;
              }

              /* General module hover effect */
              #workspaces button:hover,
              #clock:hover,
              #idle_inhibitor:hover,
              #cpu:hover,
              #memory:hover,
              #network:hover,
              #bluetooth:hover,
              #pulseaudio:hover,
              #power-profiles-daemon:hover,
              #custom-battery:hover,
              #tray:hover {
                background: rgba(255, 255, 255, 0.1);
              }

              #workspaces {
                margin: 0 4px 0 0;
                padding: 0;
              }
              #workspaces button {
                color: #727072;
                padding: 0 8px;
                margin: 3px 2px;
                transition: all 0.2s ease;
              }
              #workspaces button.visible {
                color: #fcfcfa; /* brighter than inactive gray: shown on a non-focused monitor */
              }
              #workspaces button.active {
                color: #2d2a2e;
                background: #fcfcfa; /* white, filled rectangular block for active workspace */
              }
              #workspaces button.urgent {
                color: #2d2a2e;
                background: #ff6188; /* Monokai Pink for urgent */
              }
              #workspaces button.special.active {
                color: #2d2a2e;
                background: #ffd866; /* Monokai Yellow while scratchpad is open */
              }

              #window {
                margin: 0;
                padding: 0 12px;
                color: #fcfcfa;
                font-weight: normal;
                font-style: italic;
              }

              #clock {
                margin: 3px 0;
                padding: 0 12px;
                color: #fcfcfa;
                transition: all 0.2s ease;
              }

              #idle_inhibitor {
                margin: 3px 2px;
                padding: 0 14px 0 8px;
                color: #727072;
                transition: all 0.2s ease;
              }
              #idle_inhibitor label,
              #power-profiles-daemon label {
                margin: 0;
                padding: 0;
              }
              #idle_inhibitor.activated {
                color: #ffd866; /* Monokai Yellow when sleep is inhibited */
              }

              #cpu,
              #memory {
                margin: 3px 2px;
                padding: 0 10px;
                color: #fcfcfa; /* usage is low, nothing to flag */
                transition: all 0.2s ease;
              }
              #cpu.warning,
              #memory.warning {
                color: #fc9867; /* Monokai Orange: usage is elevated */
              }
              #cpu.critical,
              #memory.critical {
                color: #ff6188; /* Monokai Pink/Red: usage is critical */
              }

              #network {
                margin: 3px 2px;
                padding: 0 10px;
                color: #727072; /* disconnected: neutral */
                transition: all 0.2s ease;
              }
              #network.wifi,
              #network.ethernet {
                color: #a9dc76; /* Monokai Green: connected */
              }
              #network.linked {
                color: #fc9867; /* Monokai Orange: interface up but no IP */
              }

              #bluetooth {
                margin: 3px 2px;
                padding: 0 10px;
                color: #727072; /* no devices connected: neutral */
                transition: all 0.2s ease;
              }
              #bluetooth.connected {
                color: #a9dc76; /* Monokai Green: device(s) connected */
              }
              #bluetooth.disabled,
              #bluetooth.off {
                color: #59575a;
              }

              #pulseaudio {
                margin: 3px 2px;
                padding: 0 10px;
                color: #ff6188; /* Monokai Pink/Red: base = loud (>=80%) */
                transition: all 0.2s ease;
              }
              #pulseaudio.quiet {
                color: #fcfcfa; /* normal volume, 0-79% */
              }
              #pulseaudio.muted {
                color: #727072;
              }

              #power-profiles-daemon {
                margin: 3px 2px;
                padding: 0 14px 0 8px;
                color: #fcfcfa;
                transition: all 0.2s ease;
              }
              #power-profiles-daemon.power-saver {
                color: #a9dc76; /* Monokai Green: efficient, low draw */
              }
              #power-profiles-daemon.performance {
                color: #ff6188; /* Monokai Pink/Red: max draw */
              }

              #custom-battery {
                margin: 3px 2px;
                padding: 0 10px;
                color: #fcfcfa;
                transition: all 0.2s ease;
              }
              #custom-battery.charging {
                color: #a9dc76; /* Monokai Green for charging */
              }
              #custom-battery.warning {
                color: #ffd866; /* Monokai Yellow for warning */
              }
              #custom-battery.critical {
                color: #ff6188; /* Monokai Pink/Red for critical */
              }

              #tray {
                margin: 3px 2px;
                padding: 0 10px;
                transition: all 0.2s ease;
              }
            '';
          };
        };
    };
}
