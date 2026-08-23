{ den, ... }:
{
  den.aspects.hyprland.provides.hyprlock =
    { user, host, ... }:
    {
      homeManager =
        { ... }:
        {
          programs.hyprlock = {
            enable = true;
            settings = {
              general = {
                disable_loading_bar = true;
                grace = 10;
                hide_cursor = true;
                no_fade_in = false;
              };
              background = [
                {
                  path = "${../../assets/wallpaper-molly.jpg}";
                  blur_passes = 2;
                  blur_size = 7;
                  noise = 0.0117;
                  contrast = 0.8916;
                  brightness = 0.8172;
                }
              ];
              input-field = [
                {
                  size = "250, 60";
                  outline_thickness = 2;
                  dots_size = 0.2;
                  dots_spacing = 0.2;
                  dots_center = true;
                  outer_color = "rgba(255, 97, 136, 1.0)"; # Amethyst pink
                  inner_color = "rgba(45, 42, 46, 0.9)";
                  font_color = "rgba(252, 252, 250, 1.0)";
                  fade_on_empty = false;
                  placeholder_text = "<i>Enter Password...</i>";
                  position = "0, -120";
                  halign = "center";
                  valign = "center";
                }
              ];
              label = [
                {
                  text = "$TIME";
                  color = "rgba(252, 252, 250, 1.0)";
                  font_size = 80;
                  font_family = "JetBrains Mono";
                  position = "0, -200";
                  halign = "center";
                  valign = "top";
                }
                {
                  text = "Welcome back, $USER";
                  color = "rgba(255, 97, 136, 1.0)";
                  font_size = 20;
                  font_family = "JetBrains Mono";
                  position = "0, -40";
                  halign = "center";
                  valign = "center";
                }
              ];
            };
          };
        };
    };
}
