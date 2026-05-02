{ den, ... }:
{
  den.aspects.cli =
    { ... }:
    {
      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            opencode
            gemini-cli
            nil
          ];
          programs.neovim = {
            enable = true;
            vimAlias = true;
            viAlias = true;
            withRuby = false;
            withPython3 = false;
          };

        };
    };
}
