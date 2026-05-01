{ inputs, den, lib, ... }: {
  den.aspects.espdesign = { # (9)
    includes = [ den.provides.define-user den.provides.primary-user (den.provides.user-shell "fish")]; # (10)
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.vim ];
    };
  };
}