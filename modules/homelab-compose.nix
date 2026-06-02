{ ... }:
{
  den.aspects.homelab-compose = {
    nixos =
      { ... }:
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
      };

    homeManager =
      { ... }:
      {
        # /mnt/seagate14/data
        home.file."docker-compose.yml".source = ./assets/homelab-compose.yml;
      };
  };
}
