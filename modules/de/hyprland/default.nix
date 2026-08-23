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
                  "--user-menu-min-uid 1000"
                  "--user-menu-max-uid 29999"
                  "--asterisks"
                  # Monokai Pro palette, matching waybar/dunst/hyprlock:
                  # container/bg=#2d2a2e, text=#fcfcfa, greet(muted)=#727072,
                  # border/action=Pink #ff6188, prompt=Orange #fc9867,
                  # title/time=Yellow #ffd866, button=Green #a9dc76
                  "--theme 'container=#2d2a2e;text=#fcfcfa;greet=#727072;border=#ff6188;action=#ff6188;prompt=#fc9867;input=#fcfcfa;title=#ffd866;time=#ffd866;button=#a9dc76'"
                  "--cmd start-hyprland"
                ];
                user = "greeter";
              };
            };
          };

          # Enable gnome-keyring and unlock it on login
          services.gnome.gnome-keyring.enable = true;
          security.pam.services.greetd.enableGnomeKeyring = true;

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
        {
          # Packages needed for Wayland environment and management
          home.packages = with pkgs; [
            wl-clipboard
            grimblast # Screen capture
            networkmanagerapplet # nm-applet tray
            pavucontrol # GUI Audio control
            brightnessctl # Brightness controls
            nautilus # Graphical File Manager
            hyprpolkitagent # Official Hyprland Polkit Agent
            hyprpaper # Wallpaper utility
            imv # Image preview/viewer
          ];

          home.pointerCursor = {
            enable = true;
            package = pkgs.bibata-cursors;
            name = "Bibata-Modern-Ice";
            size = 24;
            gtk.enable = true;
            x11.enable = true;
          };

          # GTK and Icon Theme for modern tray applets (like nm-applet)
          gtk = {
            enable = true;
            theme = {
              name = "Adwaita-dark";
              package = pkgs.gnome-themes-extra;
            };
            iconTheme = {
              name = "Papirus-Dark";
              package = pkgs.papirus-icon-theme;
            };
            gtk4.theme = null;
          };

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
              ${
                if host.hostName == "kitava" then
                  ''
                    hl.monitor({
                      output = "DP-1",
                      mode = "highrr",
                      position = "0x0",
                      scale = 1
                    })
                    hl.monitor({
                      output = "HDMI-A-1",
                      mode = "1920x1080@60",
                      position = "1920x0",
                      scale = 1
                    })

                    -- Workspace monitor rules
                    hl.workspace_rule({ workspace = "1", monitor = "DP-1" })
                    hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1" })
                  ''
                else
                  ''
                    hl.monitor({
                      output = "",
                      mode = "highrr",
                      position = "auto",
                      scale = 1
                    })
                  ''
              }

              -- System config settings
              hl.config({
                cursor = {
                  inactive_timeout = 3,
                  hide_on_key_press = true,
                },
                general = {
                  gaps_in = 3,
                  gaps_out = 4,
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
                  resize_on_border = true,
                  extend_border_grab_area = 15,
                },
                decoration = {
                  rounding = 6,
                  active_opacity = 1.0,
                  inactive_opacity = 1.0,
                  dim_special = 0.6,
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
                gestures = {
                  workspace_swipe_cancel_ratio = 0.3,
                },
              })

              -- Scratchpad: shrink it off the screen edges so it reads as a
              -- floating overlay instead of a fullscreen tile, and dim
              -- everything behind it (decoration.dim_special above).
              hl.workspace_rule({
                workspace = "special:scratchpad",
                gaps_out = { top = 80, right = 200, bottom = 80, left = 200 },
              })

              -- Gestures configuration
              hl.gesture({
                fingers = 3,
                direction = "horizontal",
                action = "workspace"
              })
              -- Plain function action fires once on gesture release with no
              -- distance/cancel-ratio check (unlike action = "special"), so it
              -- toggles instantly and never cancels partway through the swipe.
              hl.gesture({
                fingers = 3,
                direction = "up",
                action = function()
                  hl.dispatch(hl.dsp.workspace.toggle_special("scratchpad"))
                end
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
              hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("firefox"))
              hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("rofi -show drun"))
              hl.bind(mainMod .. " + Q", hl.dsp.window.close())
              hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())
              hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
              hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))

              -- Lock screen
              hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("loginctl lock-session"))

              -- Focus moves
              hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "l" }))
              hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "r" }))
              hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "u" }))
              hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "d" }))

              -- Window swap (move the window itself, not just focus)
              hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.swap({ direction = "l" }))
              hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "r" }))
              hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.swap({ direction = "u" }))
              hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.swap({ direction = "d" }))

              -- Mouse move/resize
              hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
              hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

              -- Workspaces Loop
              for i = 1, 9 do
                hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = tostring(i) }))
                hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = tostring(i) }))
              end

              -- Workspace cycling
              hl.bind(mainMod .. " + tab", hl.dsp.focus({ workspace = "e+1" }))
              hl.bind(mainMod .. " + SHIFT + tab", hl.dsp.focus({ workspace = "e-1" }))

              -- Scratchpad
              hl.bind(mainMod .. " + grave", hl.dsp.workspace.toggle_special("scratchpad"))
              hl.bind(mainMod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))

              -- Screenshots (grimblast)
              hl.bind("Print", hl.dsp.exec_cmd("grimblast copy screen"))
              hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grimblast copy active"))
              hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("grimblast copy area"))

              -- Volume controls (repeating & locked)
              hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
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
