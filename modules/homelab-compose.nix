{ ... }:
{
  den.aspects.homelab-compose =
    { user, ... }:
    {
      nixos =
        { pkgs, ... }:
        {
          hardware.graphics.enable = true;
          boot.kernelModules = [ "i915" ];

          networking.firewall.allowedTCPPorts = [
            80 # HTTP (SWAG)
            443 # HTTPS (SWAG)
            32400 # Plex
            8096 # Jellyfin
          ];
          networking.firewall.allowedUDPPorts = [
            32400 # Plex
            8096 # Jellyfin
          ];

          systemd.services.homelab-compose-update = {
            description = "Update Homelab Containers";
            after = [ "docker.service" ];
            requires = [ "docker.service" ];
            path = [ pkgs.docker ];
            script = ''
              docker compose -f /home/${user.userName}/docker-compose.yml pull
              docker compose -f /home/${user.userName}/docker-compose.yml up -d
              docker image prune -af
            '';
            serviceConfig = {
              Type = "oneshot";
              User = "root";
            };
          };

          systemd.timers.homelab-compose-update = {
            description = "Timer for updating Homelab Containers";
            timerConfig = {
              OnCalendar = "03:00:00";
              Persistent = true;
              Unit = "homelab-compose-update.service";
            };
            wantedBy = [ "timers.target" ];
          };
        };

      homeManager =
        { lib, ... }:
        {
          # /mnt/seagate14/data
          home.file."docker-compose.yml".text =
            lib.replaceStrings [ "@QBIT_MANAGE_CONFIG@" ] [ "${./assets/qbit-manage-config.yml}" ]
              (builtins.readFile ./assets/homelab-compose.yml);
        };
    };
}
