{ ... }:
{
  den.aspects.homelab-compose =
    { user, ... }:
    {
      nixos =
        { pkgs, ... }:
        let
          # Declarative qbit-manage config (share limits / recycle bin rules).
          qbManageConfig = pkgs.writeText "qbit-manage-config.yml" (
            builtins.readFile ./assets/qbit-manage-config.yml
          );
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
          ];

          # qbit-manage reads /config/config.yml from inside the container, so a symlink
          # into /nix/store dangles there (/nix is not mounted in the container).
          # Install a real file instead, before docker starts any container.
          systemd.services.qbit-manage-config = {
            description = "Install declarative qbit-manage config";
            before = [ "docker.service" ];
            wantedBy = [ "docker.service" ];
            path = [ pkgs.coreutils ];
            script = ''
              install -m 0644 -o ${user.userName} -g users \
                ${qbManageConfig} \
                /mnt/seagate14/data/config/qbit-manage/config.yml
            '';
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
          };

          systemd.services.homelab-compose-update = {
            description = "Update Homelab Containers";
            after = [ "docker.service" ];
            requires = [ "docker.service" ];
            path = [ pkgs.docker ];
            script = ''
              # A registry 429 must not cancel this run: pull what we can, then always
              # deploy and prune. Otherwise one failing image silently freezes the stack.
              docker compose --parallel=1 -f /home/${user.userName}/docker-compose.yml pull --ignore-pull-failures ||
                echo "WARNING: some images failed to pull; applying the rest"
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
