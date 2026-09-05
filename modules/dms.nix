{ den, ... }:
{
  den.aspects.dms =
    { user, host, ... }:
    {
      nixos =
        { pkgs, ... }:
        {
          # Enable Hyprland compositor with UWSM
          programs.hyprland = {
            enable = true;
            withUWSM = true;
            xwayland.enable = true;
          };

          # Session variables for Wayland & Ozone high-DPI scaling support
          environment.sessionVariables = {
            NIXOS_OZONE_WL = "1";
            ELECTRON_OZONE_PLATFORM_HINT = "auto";
          };

          # Enable DankMaterialShell
          programs.dms-shell = {
            enable = true;

            systemd = {
              enable = true;
              restartIfChanged = true;
            };

            # Core features
            enableSystemMonitoring = true;
            enableVPN = true;
            enableDynamicTheming = true;
            enableAudioWavelength = true;
            enableCalendarEvents = true;
            enableClipboardPaste = true;
          };

          # Disable GDM, enable greetd with autologin via start-hyprland
          services.displayManager.gdm.enable = false;
          services.greetd = {
            enable = true;
            settings = {
              default_session = {
                command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd start-hyprland";
                user = "greeter";
              };
              initial_session = {
                command = "start-hyprland";
                user = "espdesign";
              };
            };
          };

          # Keyring, PAM & Power Management
          services.gnome.gnome-keyring.enable = true;
          services.upower.enable = true;
          security.pam.services.greetd.enableGnomeKeyring = true;
          security.polkit.enable = true;

          # XDG Portals
          xdg.portal = {
            enable = true;
            extraPortals = [
              pkgs.xdg-desktop-portal-hyprland
              pkgs.xdg-desktop-portal-gtk
            ];
          };

          # Configure keymap in X11
          services.xserver.xkb = {
            layout = "us";
            variant = "";
          };

          # Lock screen U2F authentication service definition
          security.pam.services."dankshell-u2f".text = ''
            auth     required ${pkgs.pam_u2f}/lib/security/pam_u2f.so cue
            account  required pam_permit.so
          '';

          environment.systemPackages = with pkgs; [
            alacritty
            wl-clipboard
            dms-shell
          ];
        };

      homeManager =
        { pkgs, ... }:
        {
          home.pointerCursor = {
            enable = true;
            package = pkgs.bibata-cursors;
            name = "Bibata-Modern-Ice";
            size = 24;
            gtk.enable = true;
            x11.enable = true;
          };

          # Hyprland Lua configuration tailored for DankMaterialShell
          wayland.windowManager.hyprland = {
            enable = true;
            configType = "lua";
            extraConfig = ''
              -- Monitor configuration and scaling per host
              ${
                if host.hostName == "kitava" then
                  ''
                    hl.monitor({
                      output = "DP-1",
                      mode = "preferred",
                      position = "0x0",
                      scale = 1
                    })
                    hl.monitor({
                      output = "HDMI-A-1",
                      mode = "preferred",
                      position = "1920x0",
                      scale = 1
                    })
                    hl.monitor({
                      output = "",
                      mode = "preferred",
                      position = "auto",
                      scale = 1
                    })

                    -- Workspace monitor rules
                    hl.workspace_rule({ workspace = "1", monitor = "DP-1" })
                    hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1" })
                  ''
                else if host.hostName == "hinekora" then
                  ''
                    hl.monitor({
                      output = "",
                      mode = "preferred",
                      position = "auto",
                      scale = 1.25
                    })
                  ''
                else
                  ''
                    hl.monitor({
                      output = "",
                      mode = "preferred",
                      position = "auto",
                      scale = 1
                    })
                  ''
              }

              hl.config({
                cursor = {
                  inactive_timeout = 3,
                  hide_on_key_press = true,
                },
                general = {
                  gaps_in = 5,
                  gaps_out = 8,
                  border_size = 2,
                  col = {
                    active_border = "rgba(7fc8ffff)",
                    inactive_border = "rgba(505050ff)",
                  },
                  layout = "dwindle",
                },
                decoration = {
                  rounding = 12,
                  active_opacity = 1.0,
                  inactive_opacity = 0.95,
                },
                input = {
                  kb_layout = "us",
                  follow_mouse = 1,
                  touchpad = {
                    natural_scroll = true,
                  },
                  sensitivity = 0,
                },
                xwayland = {
                  force_zero_scaling = true,
                },
                debug = {
                  disable_scale_checks = true,
                },
                misc = {
                  disable_hyprland_logo = true,
                  disable_splash_rendering = true,
                },
              })

              -- DMS layer rules
              hl.layer_rule({ match = { namespace = "^dms" }, no_anim = true })

              -- Window rules
              hl.window_rule({ match = { class = "^(org\\.quickshell)$" }, float = true })
              hl.window_rule({ match = { class = "^(org\\.gnome\\.)" }, rounding = 12 })

              -- Startup applications
              hl.on("hyprland.start", function()
                hl.exec_cmd("wl-paste --type text --watch cliphist store")
              end)

              -- Keybindings
              local mainMod = "SUPER"

              -- Applications
              hl.bind(mainMod .. " + return", hl.dsp.exec_cmd("ghostty"))
              hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("firefox"))
              hl.bind(mainMod .. " + Q", hl.dsp.window.close())
              hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())

              -- DankMaterialShell IPC shortcuts
              hl.bind(mainMod .. " + space", hl.dsp.exec_cmd("dms ipc call spotlight toggle"))
              hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("dms ipc call clipboard toggle"))
              hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("dms ipc call processlist focusOrToggle"))
              hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd("dms ipc call settings focusOrToggle"))
              hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("dms ipc call notifications toggle"))
              hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("dms ipc call dankdash wallpaper"))
              hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd("dms ipc call lock lock"))

              -- Focus navigation
              hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "l" }))
              hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "r" }))
              hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "u" }))
              hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "d" }))
              hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "l" }))
              hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "r" }))
              hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "u" }))
              hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "d" }))

              -- Window swap
              hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.swap({ direction = "l" }))
              hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "r" }))
              hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.swap({ direction = "u" }))
              hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.swap({ direction = "d" }))

              -- Workspaces
              for i = 1, 9 do
                hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = tostring(i) }))
                hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = tostring(i) }))
              end

              -- Volume & Brightness
              hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("dms ipc call audio increment 3", { locked = true, repeating = true }))
              hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("dms ipc call audio decrement 3", { locked = true, repeating = true }))
              hl.bind("XF86AudioMute", hl.dsp.exec_cmd("dms ipc call audio mute", { locked = true }))
              hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("dms ipc call brightness increment 5 \"\"", { locked = true, repeating = true }))
              hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("dms ipc call brightness decrement 5 \"\"", { locked = true, repeating = true }))
            '';
          };
        };
    };
}
