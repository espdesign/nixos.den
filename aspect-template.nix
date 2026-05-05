{ den, ... }:
{
  den.aspects.nix-helpers =
    { user, ... }:
    {
      homeManager =
        { pkgs, ... }:
        {
          #user level
        };
      nixps =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [
            # nil
            # nh
          ];
        };
    };

}
