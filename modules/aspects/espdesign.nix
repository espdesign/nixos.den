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
      # den.aspects.dev
      # den.aspects.gnome
    ];
    nixos =
      { ... }:
      {
        users.users.espdesign.hashedPassword = "$6$kk8o25Zeru3ZiUyL$zoRQ7si4zE2As8pL6D96w/VLktcIF7Zg1Ovn976JitlkQ68LiXKneJ/vMGGR7DAowq7sXqRGQVHRkq2rQ5MTU1";
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

      };
  };

}
