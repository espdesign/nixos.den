{ den, pkgs, ... }:
{
  den.aspects.fonts = {
    nixos =
      { pkgs, ... }:
      {
        fonts.packages = with pkgs; [
          fira-code
          font-manager
          font-awesome_5
          noto-fonts
          jetbrains-mono
        ];
      };

    homeManager =
      { pkgs, ... }:
      {
        # Fonts are installed system-wide via nixos.fonts.packages
      };
  };
}
