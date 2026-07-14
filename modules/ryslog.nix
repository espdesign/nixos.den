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
        # Open the standard syslog port in your NixOS firewall
        networking.firewall.allowedUDPPorts = [ 514 ];
      };
  };
}
