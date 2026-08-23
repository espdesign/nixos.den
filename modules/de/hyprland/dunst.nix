{ den, ... }:
{
  den.aspects.hyprland.provides.dunst =
    { user, host, ... }:
    {
      homeManager =
        { ... }:
        {
          services.dunst = {
            enable = true;
            settings = {
              global = {
                font = "Sans 10";
                markup = "full";
                format = "<b>%s</b>\n%b";
                sort = "yes";
                indicate_hidden = "yes";
                alignment = "left";
                show_age_threshold = 60;
                word_wrap = "yes";
                ignore_newline = "no";
                stack_duplicates = "true";
                hide_duplicate_count = "false";
                show_indicators = "yes";
                icon_position = "left";
                max_icon_size = 32;

                background = "#2d2a2e";
                foreground = "#fcfcfa";
                frame_color = "#ffd866";
                frame_width = 2;
                separator_color = "frame";
                corner_radius = 8;
              };

              urgency_low = {
                background = "#2d2a2e";
                foreground = "#727072";
                timeout = 5;
              };

              urgency_normal = {
                background = "#2d2a2e";
                foreground = "#fcfcfa";
                timeout = 10;
              };

              urgency_critical = {
                background = "#2d2a2e";
                foreground = "#ff6188";
                frame_color = "#ff6188";
                timeout = 0;
              };
            };
          };
        };
    };
}
