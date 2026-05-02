{ den, ... }:
{
  den.aspects.cli = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          gh
          opencode
          gemini-cli
          nil
          vim
        ];

      };
  };
}
