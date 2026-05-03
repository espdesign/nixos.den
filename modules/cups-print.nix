{ den, ... }:
{
  den.aspects.cups-print = {
    nixos =
      { ... }:
      {
        # 1. Enable CUPS to print documents.
        services.printing.enable = true;

        # 2. Enable Autodiscovery of Network Printers
        services.avahi = {
          enable = true;
          nssmdns4 = true;
          openFirewall = true; # Open UDP 5353 for Avahi
        };
      };
  };
}
