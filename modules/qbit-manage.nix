{ lib, ... }:
{
  den.aspects.qbit-manage = {
    nixos =
      { pkgs, ... }:
      let
        configTemplate = pkgs.writeText "qbit-manage-config.yml" ''
          commands:
            share_limits: true
            tag_update: true
            skip_qb_version_check: true

          qbt:
            host: "http://localhost:8080"
            user: "$QBT_USER"
            pass: "$QBT_PASS"

          directory:
            root_dir: "/data"

          cat:
            Uncategorized: "/data/*"

          tracker:
            czteam.me:
              tag: czteam

          share_limits:
            strict_seeding:
              priority: 1
              include_all_tags:
                - czteam
              max_ratio: 2.0
              max_time: 4320
              strategy: last_no_matter_what
              cleanup: true
            default:
              priority: 2
              max_ratio: 0.0
              strategy: last_no_matter_what
              cleanup: true
        '';

        qbitWrapper = pkgs.writeShellScript "qbit-manage-wrapper" ''
          set -euo pipefail

          ENV_FILE="/mnt/seagate14/data/config/qbit-manage/env"
          CONFIG_DIR=$(mktemp -d)

          if [ -f "$ENV_FILE" ]; then
            set -a
            . "$ENV_FILE"
            set +a
          else
            echo "WARNING: $ENV_FILE not found." >&2
            echo "Create it with:" >&2
            echo "  sudo mkdir -p /mnt/seagate14/data/config/qbit-manage" >&2
            echo "  echo 'QBT_USER=admin' | sudo tee $ENV_FILE" >&2
            echo "  echo 'QBT_PASS=yourpassword' | sudo tee -a $ENV_FILE" >&2
            echo "  sudo chmod 600 $ENV_FILE" >&2
            QBT_USER="admin"
            QBT_PASS="adminadmin"
          fi

          export QBT_USER QBT_PASS
          ${pkgs.gettext}/bin/envsubst '$QBT_USER $QBT_PASS' < ${configTemplate} > "$CONFIG_DIR/config.yml"

          exec ${pkgs.qbit-manage}/bin/qbit-manage --run --config-dir "$CONFIG_DIR" "$@"
        '';

      in
      {
        nixpkgs.overlays = [
          # Use the develop branch for qBittorrent 5.2.0 support
          (final: prev: {
            qbit-manage = prev.python3Packages.buildPythonApplication {
              pname = "qbit-manage";
              version = "4.7.1-develop6";

              src = prev.fetchFromGitHub {
                owner = "StuffAnThings";
                repo = "qbit_manage";
                rev = "ff54453fd92663e5779799d821f228d4090f8d79";
                hash = "sha256-2qd5zzt5a7wJKC6usvc5KLHV7fXT0pG4znlmmcqgvl8=";
              };

              pyproject = true;
              build-system = [ prev.python3Packages.setuptools ];

              postPatch = ''
                substituteInPlace pyproject.toml --replace "==" ">="
              '';

              dependencies = with prev.python3Packages; [
                argon2-cffi
                bencode-py
                croniter
                fastapi
                gitpython
                humanize
                pytimeparse2
                qbittorrent-api
                requests
                retrying
                ruamel-yaml
                slowapi
                uvicorn
              ];

              pythonRelaxDeps = [
                "croniter"
                "fastapi"
                "gitpython"
                "qbittorrent-api"
                "requests"
                "uvicorn"
              ];

              meta = {
                description = "This tool will help manage tedious tasks in qBittorrent and automate them";
                homepage = "https://github.com/StuffAnThings/qbit_manage";
                license = lib.licenses.mit;
                platforms = lib.platforms.all;
                mainProgram = "qbit-manage";
              };
            };
          })
        ];

        environment.systemPackages = [ pkgs.qbit-manage ];

        systemd.services.qbit-manage = {
          description = "qBitManage Seeding Enforcement";
          after = [ "network.target" "network-online.target" ];
          wants = [ "network-online.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${qbitWrapper}";
          };
        };

        systemd.timers.qbit-manage = {
          description = "Run qBitManage every hour";
          timerConfig = {
            OnBootSec = "5m";
            OnUnitActiveSec = "1h";
            Unit = "qbit-manage.service";
          };
          wantedBy = [ "timers.target" ];
        };
      };
  };
}
