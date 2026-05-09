{ ... }:
{
  den.aspects.homelab-compose = {
    homeManager =
      { ... }:
      {
        # /mnt/seagate14/data
        home.file."docker-compose.yml".text = ''
          services:
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
              environment:
                - PUID=1000
                - PGID=1000
                - TZ=America/New_York
              volumes:
                - /mnt/seagate14/data/config/sonarr:/config
                - /mnt/seagate14/data:/data
              ports:
                - 8989:8989
              restart: unless-stopped

            radarr:
              image: lscr.io/linuxserver/radarr:latest
              container_name: radarr
              environment:
                - PUID=1000
                - PGID=1000
                - TZ=America/New_York
              volumes:
                - /mnt/seagate14/data/config/radarr:/config
                - /mnt/seagate14/data:/data
              ports:
                - 7878:7878
              restart: unless-stopped

            prowlarr:
              image: lscr.io/linuxserver/prowlarr:latest
              container_name: prowlarr
              environment:
                - PUID=1000
                - PGID=1000
                - TZ=America/New_York
              volumes:
                - /mnt/seagate14/data/config/prowlarr:/config
              ports:
                - 9696:9696
              restart: unless-stopped

            qbittorrent:
              image: lscr.io/linuxserver/qbittorrent:latest
              container_name: qbittorrent
              environment:
                - PUID=1000
                - PGID=1000
                - TZ=America/New_York
                - WEBUI_PORT=8080
              volumes:
                - /mnt/seagate14/data/config/qbittorrent:/config
                - /mnt/seagate14/data/downloads:/data/downloads
              ports:
                - 8080:8080
                - 6881:6881
                - 6881:6881/udp
              restart: unless-stopped
        '';
      };
  };
}
