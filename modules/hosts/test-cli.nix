{
  den,
  ...
}:
{
  den.aspects.test-cli = {
    includes = [
      den.provides.hostname
      (den.provides.tty-autologin "espdesign")
    ];
    provides.to-users.includes = [
      den.aspects.cli
    ];
    nixos =
      { ... }:
      {
        # Minimal CLI-only host configuration
        fileSystems."/" = {
          device = "/dev/null";
          fsType = "ext4";
        };
      };
  };
}
