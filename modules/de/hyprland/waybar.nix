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
          fontSize = if isHiDPI then "16px" else "12px";
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
                  format = "{:%I:%M %p - %a, %b %d}";
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

            # Monokai Pro Modular Block CSS styling for Waybar
            style = ''
              * {
                border: none;
                border-radius: 0;
                font-family: "JetBrainsMono Nerd Font", sans-serif;
                font-size: ${fontSize};
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
                margin: 4px 2px;
                border-radius: 8px;
              }
              #workspaces button.visible {
                color: #fcfcfa; /* brighter than inactive gray: shown on a non-focused monitor */
              }
              #workspaces button.active {
                color: #2d2a2e;
                background: #fcfcfa; /* white, filled pill for the truly focused workspace */
              }
              #workspaces button.urgent {
                color: #ff6188; /* Monokai Pink for urgent */
              }
              #workspaces button.special.active {
                color: #2d2a2e;
                background: #ffd866; /* Monokai Yellow, filled pill only while the scratchpad is open */
              }

              #window {
                background: transparent;
                margin: 5px 5px 5px 0;
                padding: 0 8px;
                color: #fcfcfa;
                font-weight: normal;
                font-style: italic;
              }

              #clock {
                background: #2d2a2e;
                border: 2px solid #727072;
                border-radius: 12px;
                margin: 5px;
                padding: 0 12px;
                color: #fcfcfa;
              }

              #idle_inhibitor {
                background: #2d2a2e;
                border: 2px solid #727072;
                border-radius: 12px;
                margin: 5px;
                /* the eye-slash glyph's ink nearly fills its full em-box,
                   so at the base font-size it crosses over the pill's
                   border instead of sitting inside it */
                padding: 2px 16px 2px 10px;
                font-size: 0.8em;
                color: #727072;
              }
              #idle_inhibitor.activated {
                color: #ffd866; /* Monokai Yellow when sleep is inhibited */
                border-color: #ffd866;
              }

              #cpu,
              #memory {
                background: #2d2a2e;
                border: 2px solid #727072;
                border-radius: 12px;
                margin: 5px;
                padding: 0 12px;
                color: #fcfcfa; /* usage is low, nothing to flag */
              }
              #cpu.warning,
              #memory.warning {
                color: #fc9867; /* Monokai Orange: usage is elevated */
                border-color: #fc9867;
              }
              #cpu.critical,
              #memory.critical {
                color: #ff6188; /* Monokai Pink/Red: usage is critical */
                border-color: #ff6188;
              }

              #network {
                background: #2d2a2e;
                border: 2px solid #727072;
                border-radius: 12px;
                margin: 5px;
                padding: 0 12px;
                color: #727072; /* disconnected: neutral, nothing is wrong, just idle */
              }
              #network.wifi,
              #network.ethernet {
                color: #a9dc76; /* Monokai Green: connected */
                border-color: #a9dc76;
              }
              #network.linked {
                color: #fc9867; /* Monokai Orange: interface up but no IP */
                border-color: #fc9867;
              }

              #bluetooth {
                background: #2d2a2e;
                border: 2px solid #727072;
                border-radius: 12px;
                margin: 5px;
                padding: 0 12px;
                color: #727072; /* no devices connected: neutral */
              }
              #bluetooth.connected {
                color: #a9dc76; /* Monokai Green: device(s) connected */
                border-color: #a9dc76;
              }
              #bluetooth.disabled,
              #bluetooth.off {
                color: #403e41;
                border-color: #403e41;
              }

              #pulseaudio {
                background: #2d2a2e;
                border: 2px solid #ff6188;
                border-radius: 12px;
                margin: 5px;
                padding: 0 12px;
                color: #ff6188; /* Monokai Pink/Red: base = loud (>=80%, no .quiet class applied) */
              }
              #pulseaudio.quiet {
                color: #fcfcfa; /* normal volume, 0-79% */
                border-color: #727072;
              }
              #pulseaudio.muted {
                color: #727072;
                border-color: #403e41;
              }

              #power-profiles-daemon {
                background: #2d2a2e;
                border: 2px solid #727072;
                border-radius: 12px;
                margin: 5px;
                padding: 0 16px 0 12px;
                color: #fcfcfa;
              }
              #power-profiles-daemon.power-saver {
                color: #a9dc76; /* Monokai Green: efficient, low draw */
                border-color: #a9dc76;
              }
              #power-profiles-daemon.performance {
                color: #ff6188; /* Monokai Pink/Red: max draw */
                border-color: #ff6188;
              }

              #custom-battery {
                background: #2d2a2e;
                border: 2px solid #727072;
                border-radius: 12px;
                margin: 5px;
                padding: 0 12px;
                color: #fcfcfa;
              }
              #custom-battery.charging {
                /* AC is connected - always green, even when the kernel
                   reports "discharging" due to charge-conservation
                   hysteresis (battery coasting down within its threshold
                   band while still plugged in) */
                color: #a9dc76; /* Monokai Green for charging */
                border-color: #a9dc76;
              }
              #custom-battery.warning {
                color: #ffd866; /* Monokai Yellow for warning */
                border-color: #ffd866;
              }
              #custom-battery.critical {
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
