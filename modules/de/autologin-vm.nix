{ den, ... }:
{
  # Parametric aspect for VM-only autologin.
  # When included in a user's context, it uses that user's name.
  den.aspects.autologin-vm =
    { user, ... }:
    {
      nixos =
        { config, lib, ... }:
        {
          virtualisation.vmVariant = lib.mkIf config.services.displayManager.enable {
            services.displayManager.autoLogin.enable = true;
            services.displayManager.autoLogin.user = user.userName;
          };
        };
    };
}
