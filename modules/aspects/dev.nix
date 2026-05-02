{ den, ... }:
{
  den.aspects.dev = {
    includes = [
      den.aspects.cli
    ];

    nixos =
      { ... }:
      {
        # Useful for many dev tools and scripts that expect /usr/bin/env
        # Keep this at system level as it's a global service.
        # services.envfs.enable = true;
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          # --- Build Tools ---
          # gnumake
          # gcc
          # binutils
          # pkg-config
          # gdb
          # strace

          # --- Nix Development ---
          nixfmt
          nix-tree
          nix-output-monitor

          # --- Common Utils ---
          jq
          yq-go
          fzf
          ripgrep
          fd
          tree
          wget
          curl
          # --- Text Editor ---
          vim
        ];

        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
      };
  };
}
