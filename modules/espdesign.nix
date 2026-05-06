{
  inputs,
  den,
  lib,
  ...
}:
{
  den.aspects.espdesign = {
    includes = [
      den.provides.define-user
      den.provides.primary-user
      (den.provides.user-shell "zsh")
      den.aspects.autologin-vm
    ];
    nixos =
      { ... }:
      {
        users.users.espdesign = {
          initalHashedPassword = "$6$kk8o25Zeru3ZiUyL$zoRQ7si4zE2As8pL6D96w/VLktcIF7Zg1Ovn976JitlkQ68LiXKneJ/vMGGR7DAowq7sXqRGQVHRkq2rQ5MTU1";
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGPhmanAAkAGH5uCbfbzreywiWKZxb0IABvatKPg52Tj evanpendergraft@gmail.com"
          ];
        };
      };

    homeManager =
      { pkgs, ... }:
      {
        programs.git = {
          enable = true;
          signing.format = null;
          settings = {
            user = {
              name = "espdesign";
              email = "evanpendergraft@gmail.com";
            };

            init = {
              defaultBranch = "main";
            };

            pull = {
              rebase = true;
            };
          };
        };
        services.syncthing = {
          enable = true;
          overrideDevices = false;
          overrideFolders = false;

          settings = {
            devices = {
              "homelab" = {
                id = "2B5LXHB-NE2FZ3F-M34RP6Y-G3NS2PD-JGN6CUH-KV3FWVI-ZAXEEJ5-QIZ77A3";
              };
            };
            folders = {
              "syncdocs" = {
                id = "gfrgi-utm7w";
                path = "~/Syncthing";
                devices = [ "homelab" ];
              };
            };
          };
        };

      };
  };

}
