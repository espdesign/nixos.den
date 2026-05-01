{ inputs, den, lib, ... }: {
  imports = [ inputs.den.flakeModule ]; # (1)

  den.schema.user.classes = lib.mkDefault [ "homeManager" ]; # (2)

  den.default.homeManager.home.stateVersion = "25.11"; # (3)

  den.hosts.x86_64-linux.framework.users.espdesign = {}; # (4) (5)

  den.aspects.framework = { # (6)
    includes = [ den.provides.hostname ]; # (7)
    nixos = { pkgs, ... }: {
      imports = [ ./_nixos/configuration.nix ]; # (8)
      environment.systemPackages = with pkgs; [ firefox vscodium ];
      nix.settings.experimental-features = ["nix-command" "flakes"];
    };
  };

  den.aspects.espdesign = { # (9)
    includes = [ den.provides.define-user den.provides.primary-user ]; # (10)
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.vim ];
    };
  };
}
