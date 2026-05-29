{ ... }:
{
  den.aspects.homelab-compose = {
    nixos =
      { ... }:
      {
        networking.firewall.allowedTCPPorts = [
          32400 # Plex
          8096  # Jellyfin
        ];
        networking.firewall.allowedUDPPorts = [
          32400 # Plex
          8096  # Jellyfin
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
                - NET_RAW
              devices:
                - /dev/net/tun:/dev/net/tun
              ports:
                - 8989:8989 # sonarr
                - 7878:7878 # radarr
                - 9696:9696 # prowlarr
                - 8080:8080 # qbittorrent webui
                - 51735:51735 # qbittorrent
                - 51735:51735/udp
              volumes:
                - /mnt/seagate14/data/config/gluetun:/gluetun
              env_file:
                - /mnt/seagate14/data/config/gluetun/secrets.env
              environment:
                - VPN_SERVICE_PROVIDER=airvpn
                - FIREWALL_VPN_INPUT_PORTS=51735
                - VPN_TYPE=wireguard
                - TZ=America/New_York
                - DNS_OVER_TLS=True
                - DNS_ADDRESS=1.1.1.1
                - FIREWALL_OUTBOUND_SUBNETS=172.16.0.0/12,192.168.0.0/16
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

            jellyfin:
              image: lscr.io/linuxserver/jellyfin:latest
              container_name: jellyfin
              environment:
                - PUID=1000
                - PGID=1000
                - TZ=America/New_York
              ports:
                - 8096:8096
              volumes:
                - /mnt/seagate14/data/config/jellyfin:/config
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
                - QBITTORRENT__Advanced__NetworkInterface=tun0
                - QBITTORRENT__Advanced__OptionalIPAddress=0.0.0.0
                - QBITTORRENT__BitTorrent__Session\Interface=tun0
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
        home.file."/mnt/seagate14/data/config/swag/nginx/proxy-confs/jellyfin.subdomain.conf".text = ''
          server {
              listen 443 ssl;
              listen [::]:443 ssl;
              server_name jellyfin.*;
              include /config/nginx/ssl.conf;
              client_max_body_size 0;
              location / {
                  include /config/nginx/proxy.conf;
                  resolver 127.0.0.11 valid=30s;
                  set $upstream_app jellyfin;
                  set $upstream_port 8096;
                  set $upstream_proto http;
                  proxy_pass $upstream_proto://$upstream_app:$upstream_port;
              }
              location /socket {
                  include /config/nginx/proxy.conf;
                  resolver 127.0.0.11 valid=30s;
                  set $upstream_app jellyfin;
                  set $upstream_port 8096;
                  set $upstream_proto http;
                  proxy_pass $upstream_proto://$upstream_app:$upstream_port;
                  proxy_http_version 1.1;
                  proxy_set_header Upgrade $http_upgrade;
                  proxy_set_header Connection "upgrade";
              }
          }
        '';
      };
  };
}
