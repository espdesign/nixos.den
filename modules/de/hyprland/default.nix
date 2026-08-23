{ den, ... }:
{
  den.aspects.hyprland =
    { user, host, ... }:
    {
      includes = [
        den.aspects.hyprland.provides.waybar
        den.aspects.hyprland.provides.rofi
        den.aspects.hyprland.provides.dunst
        den.aspects.hyprland.provides.hyprlock
        den.aspects.hyprland.provides.hypridle
      ];

      nixos =
        { pkgs, ... }:
        {
          # Enable Hyprland system-wide
          programs.hyprland = {
            enable = true;
            xwayland.enable = true;
          };

          # Enable greetd for login
          services.greetd = {
            enable = true;
            settings = {
              default_session = {
                command = pkgs.lib.concatStringsSep " " [
                  "${pkgs.tuigreet}/bin/tuigreet"
                  "--time"
                  "--remember"
                  "--remember-user-session"
                  "--user-menu"
                  "--asterisks"
                  "--theme 'border=red;text=gray;prompt=orange;time=yellow;action=red'"
                  "--cmd start-hyprland"
                ];
                user = "greeter";
              };
            };
          };

          # Hardware controls and monitoring
          hardware.bluetooth.enable = true;
          services.blueman.enable = true;
          services.upower.enable = true;

          # Hint Electron apps to use Wayland
          environment.sessionVariables = {
            NIXOS_OZONE_WL = "1";
            WLR_NO_HARDWARE_CURSORS = "1";
          };
        };

      homeManager =
        { pkgs, ... }:
        let
          mod = "SUPER";
        in
        {
          # Packages needed for Wayland environment and management
          home.packages = with pkgs; [
            wl-clipboard
            grimblast                # Screen capture
            networkmanagerapplet    # nm-applet tray
            pavucontrol             # GUI Audio control
            brightnessctl           # Brightness controls
            nautilus                # Graphical File Manager
            hyprpolkitagent         # Official Hyprland Polkit Agent
            hyprpaper               # Wallpaper utility
          ];

          # Write wallpaper configuration manually for hyprpaper v0.8+ block syntax compatibility
          xdg.configFile."hypr/hyprpaper.conf".text = ''
            wallpaper {
                monitor = *
                path = ${../../assets/wallpaper-molly.jpg}
            }
            ipc = on
          '';

          # Hyprland Config
          wayland.windowManager.hyprland = {
            enable = true;
            configType = "lua";
            extraConfig = ''
              -- Monitor configuration
              hl.monitor({
                output = "",
                mode = "preferred",
                position = "auto",
                scale = 1
              })

              -- System config settings
              hl.config({
                general = {
                  gaps_in = 5,
                  gaps_out = 10,
                  border_size = 2,
                  col = {
                    active_border = {
                      colors = { "rgba(ff6188ee)", "rgba(ffd866ee)" },
                      angle = 45
                    },
                    inactive_border = "rgba(727072aa)",
                  },
                  layout = "dwindle",
                  allow_tearing = false,
                },
                decoration = {
                  rounding = 10,
                  active_opacity = 1.0,
                  inactive_opacity = 1.0,
                  shadow = {
                    enabled = true,
                    range = 4,
                    render_power = 3,
                    color = "rgba(1a1a1aee)",
                  },
                  blur = {
                    enabled = true,
                    size = 3,
                    passes = 1,
                  },
                },
                animations = {
                  enabled = false,
                },
                dwindle = {
                  preserve_split = true,
                },
                input = {
                  kb_layout = "us",
                  follow_mouse = 1,
                  touchpad = {
                    natural_scroll = true,
                  },
                  sensitivity = 0,
                },
                misc = {
                  disable_hyprland_logo = true,
                  disable_splash_rendering = true,
                },
              })

              -- Gestures configuration
              hl.gesture({
                fingers = 3,
                direction = "horizontal",
                action = "workspace"
              })

              -- Startup applications
              hl.on("hyprland.start", function()
                hl.exec_cmd("hyprpaper")
                hl.exec_cmd("waybar")
                hl.exec_cmd("dunst")
                hl.exec_cmd("nm-applet --indicator")
                hl.exec_cmd("blueman-applet")
                hl.exec_cmd("systemctl --user start hyprpolkitagent")
              end)

              -- Keybindings
              local mainMod = "SUPER"

              -- Applications & Utilities
              hl.bind(mainMod .. " + return", hl.dsp.exec_cmd("ghostty"))
              hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("rofi -show drun"))
              hl.bind(mainMod .. " + Q", hl.dsp.window.close())
              hl.bind(mainMod .. " + M", hl.dsp.exit())
              hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
              hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))

              -- Lock screen
              hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("loginctl lock-session"))

              -- Focus moves
              hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "l" }))
              hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "r" }))
              hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "u" }))
              hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "d" }))

              -- Workspaces Loop
              for i = 1, 9 do
                hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = tostring(i) }))
                hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = tostring(i) }))
              end

              -- Volume controls (repeating & locked)
              hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
              hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })
              hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

              -- Brightness controls (repeating & locked)
              hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { repeating = true, locked = true })
              hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { repeating = true, locked = true })
            '';
          };
        };
    };
}
