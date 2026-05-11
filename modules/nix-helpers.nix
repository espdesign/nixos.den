{
  den.aspects.nix-helpers = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          nil # nix language server
          nh # nix helper
          nixd # nix language server
          nixfmt # nix formater
          nix-tree
          nix-output-monitor
          cachix
        ];
        nix.settings = {
          extra-substituters = [ "https://espdesign.cachix.org" ];
          extra-trusted-public-keys = [ "espdesign.cachix.org-1:34FPcbdU/W26YZRFCqIrVcF6uzLkcuUZvUTN5kqxebA=" ];
        };
        programs.nh = {
          enable = true;
          clean.enable = true;
          clean.extraArgs = "--keep-since 4d --keep 3";
        };
      };

    homeManager = {
      #none
    };
  };
}
