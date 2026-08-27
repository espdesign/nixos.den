{ den, ... }:
{
  den.aspects.hyprland.provides.rofi =
    { user, host, ... }:
    {
      homeManager =
        { pkgs, ... }:
        {
          programs.rofi = {
            enable = true;
            package = pkgs.rofi;
            theme = ./monokai-pro.rasi;
            extraConfig = {
              modes = "combi,drun,window";
              combi-modes = "window,drun";
            };
          };
        };
    };
}
