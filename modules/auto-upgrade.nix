{ den, ... }:
{
  den.aspects.auto-upgrade =
    { host, ... }:
    {
      nixos =
        {
          pkgs,
          lib,
          config,
          ...
        }:
        let
          flakeUri = "github:espdesign/nixos.den#${host.hostName}";

          notifyDesktop = pkgs.writeShellScript "notify-desktop" ''
            TITLE="$1"
            BODY="$2"
            URGENCY="''${3:-normal}"
            ICON="''${4:-system-software-update}"

            for uid_dir in /run/user/[0-9]*; do
              [ -d "$uid_dir" ] || continue
              uid="$(basename "$uid_dir")"
              bus="$uid_dir/bus"
              if [ -S "$bus" ]; then
                user_name="$(id -nu "$uid" 2>/dev/null || true)"
                if [ -n "$user_name" ]; then
                  if [ "$(id -u)" -eq 0 ]; then
                    ${pkgs.util-linux}/bin/runuser -u "$user_name" -- env \
                      DBUS_SESSION_BUS_ADDRESS="unix:path=$bus" \
                      ${pkgs.libnotify}/bin/notify-send \
                        --urgency="$URGENCY" \
                        --icon="$ICON" \
                        "$TITLE" "$BODY" 2>/dev/null || true
                  elif [ "$(id -u)" -eq "$uid" ]; then
                    DBUS_SESSION_BUS_ADDRESS="unix:path=$bus" \
                    ${pkgs.libnotify}/bin/notify-send \
                      --urgency="$URGENCY" \
                      --icon="$ICON" \
                      "$TITLE" "$BODY" 2>/dev/null || true
                  fi
                fi
              fi
            done
          '';

          updateScript = pkgs.writeShellApplication {
            name = "update-system";
            runtimeInputs = [
              pkgs.nixos-rebuild
              pkgs.git
              pkgs.coreutils
              pkgs.libnotify
            ];
            text = ''
              FLAKE_TARGET="${flakeUri}"

              echo "=========================================="
              echo " NixOS System Update"
              echo " Target: $FLAKE_TARGET"
              echo "=========================================="
              echo ""

              "${notifyDesktop}" "System Update Started" "Fetching updates from GitHub and rebuilding system..." "normal" "system-software-update"
              echo "Fetching updates from GitHub and rebuilding system..."

              PREV_SYS="$(readlink -f /run/current-system 2>/dev/null || true)"
              BOOTED_KERNEL="$(readlink -f /run/booted-system/kernel 2>/dev/null || true)"

              set +e
              sudo nixos-rebuild switch --refresh --flake "$FLAKE_TARGET" "$@"
              STATUS=$?

              NEW_SYS="$(readlink -f /run/current-system 2>/dev/null || true)"
              NEW_KERNEL="$(readlink -f /run/current-system/kernel 2>/dev/null || true)"

              echo ""
              if [ "$STATUS" -eq 0 ]; then
                echo "=========================================="
                echo " System update completed successfully!"
                echo "=========================================="

                if [ "$PREV_SYS" = "$NEW_SYS" ]; then
                  "${notifyDesktop}" "System Up to Date" "No new changes found. System is already up to date." "low" "emblem-default"
                elif [ -n "$BOOTED_KERNEL" ] && [ -n "$NEW_KERNEL" ] && [ "$BOOTED_KERNEL" != "$NEW_KERNEL" ]; then
                  "${notifyDesktop}" "Update Finished — Restart Needed" "A new kernel/driver update was installed. Please restart your computer to apply." "critical" "system-reboot"
                else
                  "${notifyDesktop}" "Update Complete" "System updated successfully! All changes are active — no restart needed." "normal" "emblem-default"
                fi
              else
                echo "=========================================="
                echo " Update failed with error code $STATUS."
                echo "=========================================="
                "${notifyDesktop}" "Update Failed" "Update encountered an error (code $STATUS). Check terminal for details." "critical" "dialog-error"
              fi

              if [ -t 0 ]; then
                echo ""
                read -r -p "Press Enter to close..." _
              fi

              exit "$STATUS"
            '';
          };

          nixUpdateAlias = pkgs.runCommand "nix-update-alias" { } ''
            mkdir -p $out/bin
            ln -s ${updateScript}/bin/update-system $out/bin/nix-update
          '';

          desktopItem = pkgs.makeDesktopItem {
            name = "update-system";
            desktopName = "Update System";
            genericName = "System Updater";
            comment = "Pull updates from GitHub and apply";
            icon = "system-software-update";
            exec = "ghostty -e update-system";
            categories = [
              "System"
              "Settings"
            ];
          };

          normalUsers = lib.attrNames (lib.filterAttrs (_: u: u.isNormalUser) config.users.users);
        in
        {
          # 1. Automatic nightly background upgrade
          system.autoUpgrade = {
            enable = true;
            flake = flakeUri;
            # Respect committed flake.lock on GitHub; do not update flake inputs locally
            upgrade = false;
            dates = "04:00";
            persistent = true; # Catch up on missed runs when powered down
            randomizedDelaySec = "10min"; # Start shortly after boot instead of waiting up to 45m
            allowReboot = false;
            operation = "boot";
          };

          # Desktop alerts for the background service
          systemd.services.nixos-upgrade = {
            preStart = ''
              readlink -f /nix/var/nix/profiles/system > /run/nixos-upgrade-prev-system || true
              ${notifyDesktop} "System Update Started" "Downloading and preparing latest updates in the background..." "normal" "system-software-update"
            '';
            postStart = ''
              PREV_SYS="$(cat /run/nixos-upgrade-prev-system 2>/dev/null || true)"
              NEW_SYS="$(readlink -f /nix/var/nix/profiles/system 2>/dev/null || true)"
              rm -f /run/nixos-upgrade-prev-system

              if [ -n "$PREV_SYS" ] && [ -n "$NEW_SYS" ] && [ "$PREV_SYS" != "$NEW_SYS" ]; then
                # Staged for next boot -> notify that reboot is ready
                ${notifyDesktop} "Update Finished — Restart Needed" "System updates are ready. Please restart your computer when convenient to apply them." "normal" "software-update-available"
              fi
            '';
          };

          # 2. Custom commands & desktop launcher
          environment.systemPackages = [
            updateScript
            nixUpdateAlias
            desktopItem
          ];

          # 3. Allow normal users to trigger nixos-rebuild without password prompt
          security.sudo.extraRules = [
            {
              users = normalUsers;
              commands = [
                {
                  command = "/run/current-system/sw/bin/nixos-rebuild";
                  options = [ "NOPASSWD" ];
                }
                {
                  command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild";
                  options = [ "NOPASSWD" ];
                }
              ];
            }
          ];
        };
    };
}
