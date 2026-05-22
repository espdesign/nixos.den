{ den, ... }:
{
  den.aspects.update-notifier =
    { user, host, ... }:
    {
      homeManager =
        {
          pkgs,
          config,
          lib,
          ...
        }:
        let
          repoDir = "${config.home.homeDirectory}/git/nixos.den";
          updateCheckScript = pkgs.writeShellApplication {
            name = "check-nixos-updates";
            runtimeInputs = [
              pkgs.git
              pkgs.libnotify
              pkgs.openssh
            ];
            text = ''
              REPO_DIR="${repoDir}"
              if [ ! -d "$REPO_DIR" ]; then
                exit 0
              fi

              # Fetch latest from main branch, fail silently/quietly if offline or DNS issues
              if ! git -C "$REPO_DIR" fetch origin main >/dev/null 2>&1; then
                exit 0
              fi

              REMOTE_REV=$(git -C "$REPO_DIR" rev-parse origin/main)

              if [ -f /run/current-system/configuration-revision ]; then
                CURRENT_REV=$(cat /run/current-system/configuration-revision)
              else
                CURRENT_REV="unknown"
              fi

              BEHIND=false
              AHEAD=false
              if [ "$CURRENT_REV" = "unknown" ] || [ "$CURRENT_REV" = "dirty" ]; then
                LOCAL_REV=$(git -C "$REPO_DIR" rev-parse HEAD)
                if [ "$LOCAL_REV" != "$REMOTE_REV" ]; then
                  if git -C "$REPO_DIR" merge-base --is-ancestor "$LOCAL_REV" "$REMOTE_REV" 2>/dev/null; then
                    BEHIND=true
                  else
                    AHEAD=true
                  fi
                fi
              else
                if ! git -C "$REPO_DIR" merge-base --is-ancestor "$REMOTE_REV" "$CURRENT_REV" 2>/dev/null; then
                  if git -C "$REPO_DIR" merge-base --is-ancestor "$CURRENT_REV" "$REMOTE_REV" 2>/dev/null; then
                    BEHIND=true
                  else
                    AHEAD=true
                  fi
                fi
              fi

              if [ "$BEHIND" = true ]; then
                notify-send \
                  --urgency=normal \
                  --icon=software-update-available \
                  "NixOS Update Available" \
                  "New changes found on main. Run 'nix-update' to update your system."
                echo "Updates available on main. Run 'nix-update' to update."
              elif [ "$AHEAD" = true ]; then
                echo "Local changes ahead of remote. Push or update to sync."
              else
                echo "System is up to date."
              fi
            '';
          };
        in
        {
          home.packages = [ updateCheckScript ];

          systemd.user.services.update-notifier = {
            Unit = {
              Description = "Check for NixOS configuration updates on remote main branch";
              After = [ "network-online.target" ];
            };
            Service = {
              Type = "oneshot";
              ExecStart = "${updateCheckScript}/bin/check-nixos-updates";
            };
          };

          systemd.user.timers.update-notifier = {
            Unit = {
              Description = "Timer to check for NixOS configuration updates";
            };
            Timer = {
              OnBootSec = "10m";
              OnUnitActiveSec = "1h";
              Unit = "update-notifier.service";
            };
            Install = {
              WantedBy = [ "timers.target" ];
            };
          };
        };
    };
}
