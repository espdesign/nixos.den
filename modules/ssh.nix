{
  den.aspects.ssh = {
    nixos =
      { ... }:
      {
        services.openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            PermitRootLogin = "no";
          };
        };
      };
  };
}
