{ den, ... }:
{
  den.aspects.cli = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          git
          gh
          opencode
          gemini-cli
          nil
        ];
      };
  };
}
