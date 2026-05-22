{ den, ... }:
{
  den.aspects.pipewire-sound = {
    nixos =
      { ... }:
      {
        # Enable sound with pipewire.
        services.pulseaudio.enable = false;
        security.rtkit.enable = true;
        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;

          # Optional: If you want to use JACK applications
          # jack.enable = true;
        };
      };

    homeManager =
      { host, lib, ... }:
      lib.optionalAttrs (host.hostName != "hinekora") {
        services.easyeffects.enable = true;
      };
  };
}
