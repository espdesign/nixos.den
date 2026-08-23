{ den, ... }:
{
  den.aspects.hyprland.provides.hypridle =
    { user, host, ... }:
    {
      homeManager =
        { ... }:
        {
          services.hypridle = {
            enable = true;
            settings = {
              general = {
                lock_cmd = "pidof hyprlock || hyprlock";
                before_sleep_cmd = "loginctl lock-session";
                after_sleep_cmd = "hyprctl dispatch dpms on";
              };
              listener = [
                {
                  timeout = 300; # 5 min
                  on-timeout = "loginctl lock-session";
                }
                {
                  timeout = 330; # 5.5 min
                  on-timeout = "hyprctl dispatch dpms off";
                  on-resume = "hyprctl dispatch dpms on";
                }
                {
                  timeout = 1800; # 30 min
                  on-timeout = "systemctl suspend";
                }
              ];
            };
          };
        };
    };
}
