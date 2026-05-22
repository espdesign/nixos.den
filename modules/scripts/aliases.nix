{ den, ... }:
{
  den.aspects.scripts.provides.aliases =
    { user, host, ... }:
    {
      homeManager =
        { pkgs, ... }:
        {
          home.packages = [
            (pkgs.writeShellScriptBin "nix-edit" ''exec ${pkgs.vscodium}/bin/code "$HOME/git/nixos.den"'')
            (pkgs.writeShellScriptBin "nix-apply" ''exec sudo nixos-rebuild switch --flake "$HOME/git/nixos.den#${host.hostName}"'')
            (pkgs.writeShellScriptBin "nix-update" ''
              ${pkgs.git}/bin/git -C "$HOME/git/nixos.den" pull
              exec nix-apply
            '')
            (pkgs.writeShellScriptBin "nix-checkup" "exec nix-check-updates")
          ];
        };
    };
}
