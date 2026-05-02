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
      (den.provides.user-shell "fish")
    ];
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.vim
          pkgs.nixfmt
        ];
        programs.git = {
          enable = true;
          signing.format = null; # To adopt the new default behavior, set:
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
