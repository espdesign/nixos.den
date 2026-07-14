{ ... }:
{
  den.aspects.ryslog = {
    nixos =
      { ... }:
      {
        services.rsyslogd = {
          enable = true;
          extraConfig = ''
            module(load="imudp")
            input(type="imudp" port="514")

            # Save pfSense gateway entries to a dedicated file
            if $programname == 'dpinger' then /var/log/pfsense-gateways.log
          '';
        };
        services.logrotate = {
          enable = true;
          settings = {
            "/var/log/pfsense-gateways.log" = {
              frequency = "weekly";
              rotate = 4; # Keep 4 weeks of history
              maxsize = "50M"; # Rotate early if it somehow hits 50MB
              compress = true; # Compress old logs to save space
              missingok = true;
              notifempty = true;
            };
          };
        };
        # Open the standard syslog port in your NixOS firewall
        networking.firewall.allowedUDPPorts = [ 514 ];
      };
  };
}
