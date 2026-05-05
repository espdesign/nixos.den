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
        ];
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
