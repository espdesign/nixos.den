{ den, ... }:
{
  den.aspects.dms = {
    nixos =
      { pkgs, ... }:
      {
        # Enable Niri Wayland compositor
        programs.niri.enable = true;

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

        # Disable GDM, enable greetd with autologin into niri
        services.displayManager.gdm.enable = false;
        services.greetd = {
          enable = true;
          settings = {
            default_session = {
              command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd niri-session";
              user = "greeter";
            };
            initial_session = {
              command = "${pkgs.niri}/bin/niri-session";
              user = "espdesign";
            };
          };
        };

        # Keyring & PAM
        services.gnome.gnome-keyring.enable = true;
        security.pam.services.greetd.enableGnomeKeyring = true;
        security.polkit.enable = true;

        # XDG Portals
        xdg.portal = {
          enable = true;
          extraPortals = [
            pkgs.xdg-desktop-portal-gnome
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
        # Niri configuration tailored for DankMaterialShell
        xdg.configFile."niri/config.kdl".text = ''
          environment {
            XDG_CURRENT_DESKTOP "niri"
            QT_QPA_PLATFORM "wayland"
            ELECTRON_OZONE_PLATFORM_HINT "auto"
            QT_QPA_PLATFORMTHEME "gtk3"
            QT_QPA_PLATFORMTHEME_QT6 "gtk3"
          }

          spawn-at-startup "dms" "run"

          input {
            keyboard {
              xkb {
                layout "us"
              }
            }
            touchpad {
              tap
              natural-scroll
            }
          }

          layout {
            gaps 8
            center-focused-column "never"
            preset-column-widths {
              proportion 0.33333
              proportion 0.5
              proportion 0.66667
            }
            default-column-width { proportion 0.5; }
            focus-ring {
              off
            }
            border {
              width 2
              active-color "#7fc8ff"
              inactive-color "#505050"
            }
          }

          window-rule {
            match app-id=r#"^org\.gnome\."#
            draw-border-with-background false
            geometry-corner-radius 12
            clip-to-geometry true
          }

          window-rule {
            match is-active=false
            opacity 0.95
          }

          window-rule {
            geometry-corner-radius 12
            clip-to-geometry true
          }

          window-rule {
            match app-id=r#"org\.quickshell$"#
            open-floating true
          }

          binds {
            // Applications
            Mod+Return { spawn "ghostty"; }
            Mod+B { spawn "firefox"; }
            Mod+Q { close-window; }
            Mod+Shift+E { quit; }

            // DankMaterialShell IPC Binds
            Mod+Space hotkey-overlay-title="Application Launcher" {
              spawn "dms" "ipc" "call" "spotlight" "toggle";
            }
            Mod+V hotkey-overlay-title="Clipboard Manager" {
              spawn "dms" "ipc" "call" "clipboard" "toggle";
            }
            Mod+M hotkey-overlay-title="Task Manager" {
              spawn "dms" "ipc" "call" "processlist" "focusOrToggle";
            }
            Mod+Comma hotkey-overlay-title="Settings" {
              spawn "dms" "ipc" "call" "settings" "focusOrToggle";
            }
            Mod+N hotkey-overlay-title="Notification Center" {
              spawn "dms" "ipc" "call" "notifications" "toggle";
            }
            Mod+Y hotkey-overlay-title="Browse Wallpapers" {
              spawn "dms" "ipc" "call" "dankdash" "wallpaper";
            }
            Mod+Alt+L hotkey-overlay-title="Lock Screen" {
              spawn "dms" "ipc" "call" "lock" "lock";
            }

            // Audio Controls
            XF86AudioRaiseVolume allow-when-locked=true {
              spawn "dms" "ipc" "call" "audio" "increment" "3";
            }
            XF86AudioLowerVolume allow-when-locked=true {
              spawn "dms" "ipc" "call" "audio" "decrement" "3";
            }
            XF86AudioMute allow-when-locked=true {
              spawn "dms" "ipc" "call" "audio" "mute";
            }

            // Brightness Controls
            XF86MonBrightnessUp allow-when-locked=true {
              spawn "dms" "ipc" "call" "brightness" "increment" "5" "";
            }
            XF86MonBrightnessDown allow-when-locked=true {
              spawn "dms" "ipc" "call" "brightness" "decrement" "5" "";
            }

            // Navigation
            Mod+Left  { focus-column-left; }
            Mod+Down  { focus-window-down; }
            Mod+Up    { focus-window-up; }
            Mod+Right { focus-column-right; }
            Mod+H     { focus-column-left; }
            Mod+J     { focus-window-down; }
            Mod+K     { focus-window-up; }
            Mod+L     { focus-column-right; }

            Mod+Shift+Left  { move-column-left; }
            Mod+Shift+Down  { move-window-down; }
            Mod+Shift+Up    { move-window-up; }
            Mod+Shift+Right { move-column-right; }
            Mod+Shift+H     { move-column-left; }
            Mod+Shift+J     { move-window-down; }
            Mod+Shift+K     { move-window-up; }
            Mod+Shift+L     { move-column-right; }

            // Workspaces
            Mod+1 { focus-workspace 1; }
            Mod+2 { focus-workspace 2; }
            Mod+3 { focus-workspace 3; }
            Mod+4 { focus-workspace 4; }
            Mod+5 { focus-workspace 5; }
            Mod+6 { focus-workspace 6; }
            Mod+7 { focus-workspace 7; }
            Mod+8 { focus-workspace 8; }
            Mod+9 { focus-workspace 9; }

            Mod+Shift+1 { move-column-to-workspace 1; }
            Mod+Shift+2 { move-column-to-workspace 2; }
            Mod+Shift+3 { move-column-to-workspace 3; }
            Mod+Shift+4 { move-column-to-workspace 4; }
            Mod+Shift+5 { move-column-to-workspace 5; }
            Mod+Shift+6 { move-column-to-workspace 6; }
            Mod+Shift+7 { move-column-to-workspace 7; }
            Mod+Shift+8 { move-column-to-workspace 8; }
            Mod+Shift+9 { move-column-to-workspace 9; }
          }
        '';
      };
  };
}
