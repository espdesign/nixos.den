{ ... }:
{
  den.aspects.homelab-compose =
    { user, ... }:
    {
      nixos =
        { pkgs, ... }:
        let
          # Declarative qbit-manage config (share limits / recycle bin rules).
          qbManageConfig = pkgs.writeText "qbit-manage-config.yml" (builtins.readFile ./assets/qbit-manage-config.yml);
        in
        {
          hardware.graphics.enable = true;
          boot.kernelModules = [ "i915" ];

          networking.firewall.allowedTCPPorts = [
            80 # HTTP (SWAG)
            443 # HTTPS (SWAG)
            8096 # Jellyfin
          ];
          networking.firewall.allowedUDPPorts = [
            8096 # Jellyfin
          ];

          systemd.tmpfiles.rules = [
            "d /mnt/seagate14/data/config/qbit-manage 0755 ${user.userName} users -"
            "d /mnt/seagate14/data/downloads 0775 ${user.userName} users -"
            "d /mnt/seagate14/data/downloads/incomplete 0775 ${user.userName} users -"
            "L+ /mnt/seagate14/data/config/qbit-manage/config.yml - - - - ${qbManageConfig}"
          ];

          systemd.services.homelab-compose-update = {
            description = "Update Homelab Containers";
            after = [ "docker.service" ];
            requires = [ "docker.service" ];
            path = [ pkgs.docker ];
            script = ''
              docker compose --parallel=1 -f /home/${user.userName}/docker-compose.yml pull
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
        { ... }:
        {
          # /mnt/seagate14/data
          home.file."docker-compose.yml".source = ./assets/homelab-compose.yml;
        };
    };
}
