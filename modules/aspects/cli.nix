{ den, ... }:
{
  den.aspects.cli = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          opencode
          gemini-cli
          nil
          vim
        ];
        programs.neovim = {
          enable = true;
        };

      };
  };
}
