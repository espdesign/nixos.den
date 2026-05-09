{ ... }:
{
  den.aspects.homelab-compose = {
    nixos =
      { ... }:
      {
        networking.firewall.allowedTCPPorts = [
          80 # SWAG HTTP
          443 # SWAG HTTPS
          32400 # Plex
          8989 # Sonarr
          7878 # Radarr
          9696 # Prowlarr
          8080 # qBittorrent WebUI
          6881 # qBittorrent BitTorrent port
          5055 # Seerr
        ];
        networking.firewall.allowedUDPPorts = [
          32400 # Plex
          6881 # qBittorrent BitTorrent port
        ];
      };

    homeManager =
      { ... }:
      {
        # /mnt/seagate14/data
        home.file."docker-compose.yml".text = ''
          services:
            gluetun:
              image: qmcgaw/gluetun
              container_name: gluetun
              cap_add:
                - NET_ADMIN
              devices:
                - /dev/net/tun:/dev/net/tun
              ports:
                - 8989:8989 # sonarr
                - 7878:7878 # radarr
                - 9696:9696 # prowlarr
                - 8080:8080 # qbittorrent webui
                - 6881:6881 # qbittorrent
                - 6881:6881/udp
              volumes:
                - /mnt/seagate14/data/config/gluetun:/gluetun
              env_file:
                - /mnt/seagate14/data/config/gluetun/secrets.env
              environment:
                - VPN_SERVICE_PROVIDER=nordvpn
                - VPN_TYPE=wireguard
                # Use countries that are very P2P/torrent friendly
                - SERVER_COUNTRIES=Switzerland,Netherlands
                - TZ=America/New_York
              restart: unless-stopped

            plex:
              image: lscr.io/linuxserver/plex:latest
              container_name: plex
              network_mode: host
              environment:
                - PUID=1000
                - PGID=1000
                - VERSION=docker
              volumes:
                - /mnt/seagate14/data/config/plex:/config
                - /mnt/seagate14/data/media:/data/media
              restart: unless-stopped

            sonarr:
              image: lscr.io/linuxserver/sonarr:latest
              container_name: sonarr
              network_mode: "service:gluetun"
              environment:
                - PUID=1000
                - PGID=1000
                - TZ=America/New_York
              volumes:
                - /mnt/seagate14/data/config/sonarr:/config
                - /mnt/seagate14/data:/data
              restart: unless-stopped

            radarr:
              image: lscr.io/linuxserver/radarr:latest
              container_name: radarr
              network_mode: "service:gluetun"
              environment:
                - PUID=1000
                - PGID=1000
                - TZ=America/New_York
              volumes:
                - /mnt/seagate14/data/config/radarr:/config
                - /mnt/seagate14/data:/data
              restart: unless-stopped

            prowlarr:
              image: lscr.io/linuxserver/prowlarr:latest
              container_name: prowlarr
              network_mode: "service:gluetun"
              environment:
                - PUID=1000
                - PGID=1000
                - TZ=America/New_York
              volumes:
                - /mnt/seagate14/data/config/prowlarr:/config
              restart: unless-stopped

            qbittorrent:
              image: lscr.io/linuxserver/qbittorrent:latest
              container_name: qbittorrent
              network_mode: "service:gluetun"
              environment:
                - PUID=1000
                - PGID=1000
                - TZ=America/New_York
                - WEBUI_PORT=8080
              volumes:
                - /mnt/seagate14/data/config/qbittorrent:/config
                - /mnt/seagate14/data:/data
              restart: unless-stopped

            seerr:
              image: ghcr.io/seerr-team/seerr:latest
              container_name: seerr
              environment:
                - TZ=America/New_York
              ports:
                - 5055:5055
              volumes:
                - /mnt/seagate14/data/config/seerr:/app/config
              restart: unless-stopped

            swag:
              image: lscr.io/linuxserver/swag:latest
              container_name: swag
              cap_add:
                - NET_ADMIN
              environment:
                - PUID=1000
                - PGID=1000
                - TZ=America/New_York
              env_file:
                - /mnt/seagate14/data/config/swag/secrets.env
              volumes:
                - /mnt/seagate14/data/config/swag:/config
              ports:
                - 443:443
                - 80:80
              restart: unless-stopped
        '';
      };
  };
}
