{ den, ... }:
{
  den.aspects.cli = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          git
          gh
          opencode
          gemini-cli
          nil
        ];
      };
  };
}
