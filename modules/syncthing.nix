{ den, ... }:
{
  den.aspects.syncthing =
    { user, host, ... }:
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
          settings = {
            devices = {
              "hinekora" = {
                id = "VJO634U-X3QOZCY-WFYRUQJ-UY46F6H-QB2QIFV-DUVVGGA-IA4UYYG-EKQGJAZ";
              };
              "kitava" = {
                id = "SC5QXOP-IO5WX6O-UPBQHJ7-MBK52OH-BPICW2P-7NCA3PF-CFRZU6L-BD2OHQO";
              };
              "valako" = {
                id = "O74L64E-XYLKVX5-5D6WKWN-C4ICOUM-JYYS3P5-PZR5N2I-UVETX2Q-O5ZAOAS";
              };
            };
            folders = {
              "syncdocs" = {
                id = "gfrgi-utm7w";
                path = "~/Syncthing";
                devices = [
                  "hinekora"
                  "kitava"
                  "valako"
                ];
              };
            };
          };
        };
      };
    };
}
