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
      };
  };
}
