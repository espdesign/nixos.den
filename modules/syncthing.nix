{ den, ... }:
{
  den.aspects.syncthing =
    { ... }:
    {
      nixos = {
        networking.firewall.allowedTCPPorts = [ 22000 ];
        networking.firewall.allowedUDPPorts = [ 21027 ];
      };
      homeManager = {
        services.syncthing = {
          enable = true;
          overrideDevices = false;
          overrideFolders = false;
        };
      };
    };
}
