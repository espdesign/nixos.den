{ den, ... }:
{
  den.aspects.dev =
    { user, ... }:
    {
      includes = [
        den.aspects.cli
      ];

      nixos =
        { ... }:
        {
          # Useful for many dev tools and scripts that expect /usr/bin/env
          # Keep this at system level as it's a global service.
          # services.envfs.enable = true;

          # enable docker
          virtualisation.docker.enable = true;
          users.extraGroups.docker.members = [ user.userName ];
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
            vscodium

          ];

          programs.direnv = {
            enable = true;
            nix-direnv.enable = true;
          };
        };
    };
}
