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
              initialHashedPassword = "$6$gMclef8wWibtLst0$6f0JIElUbX3DvW78zAOhLOesfigbHrMN0hzRgTDZaFjbG8uP6Nkzjm4an1AM0VriCyrLG8ECrHIJn.6OHbgdP0";

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
