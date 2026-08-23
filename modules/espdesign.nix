{
  den,
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
          initialHashedPassword = "$6$.RsSG5NHxmaVau/P$VkymnLbhoKuEujZCWmp5vDBOby4./c4QxqGMW8VGrOnRt139YUxb7BTv3zSRkrJgBPi8Hn5lZ2NYA0L4l6zeJ.";
          extraGroups = [ "kvm" ];
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBVT8QAQNC1TJROywn6DfVEbRmcuTjVlKBar+4OOZZ1S"
          ];
        };
        networking.firewall = {
          enable = true;
        };

      };

    homeManager =
      { pkgs, ... }:
      {
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          settings = {
            "*" = {
              AddKeysToAgent = "yes";
              IdentityFile = "~/.ssh/id_ed25519_main";
            };
          };
        };

        home.packages = with pkgs; [
          ghostty.terminfo
        ];
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
      };
  };

}
