{ ... }:
{
  den.aspects.gnome = {
    nixos = {
      # Enable the GNOME Desktop Environment.
      services.displayManager.gdm.enable = true;
      services.desktopManager.gnome.enable = true;

      # Configure keymap in X11
      services.xserver.xkb = {
        layout = "us";
        variant = "";
      };
    };
    homeManager = {
      
    }
  };
}
