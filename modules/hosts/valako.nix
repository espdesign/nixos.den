{
  den,
  inputs,
  ...
}:
{
  den.aspects.valako = {
    includes = [
      den.provides.hostname
    ];
    provides.to-users.includes = [
      den.aspects.cli
      den.aspects.docker
      den.aspects.homelab-compose
      den.aspects.qbit-manage
    ];
    nixos =
      { ... }:
      {
        imports = [ inputs.disko.nixosModules.disko ];

        # Disko configuration
        disko.devices = {
          disk = {
            main = {
              device = "/dev/disk/by-id/ata-TECHLEAF-SSD_128G_GSWB2211980050";
              type = "disk";
              content = {
                type = "gpt";
                partitions = {
                  ESP = {
                    type = "EF00";
                    size = "500M";
                    content = {
                      type = "filesystem";
                      format = "vfat";
                      mountpoint = "/boot";
                    };
                  };
                  root = {
                    size = "100%";
                    content = {
                      type = "filesystem";
                      format = "ext4";
                      mountpoint = "/";
                    };
                  };
                };
              };
            };
          };
        };

        # Data drive mount using stable hardware ID
        fileSystems."/mnt/seagate14" = {
          device = "/dev/disk/by-id/usb-Seagate_Expansion_HDD_00000000NAC6KLWB-0:0";
          fsType = "auto";
        };
      };
  };
}
