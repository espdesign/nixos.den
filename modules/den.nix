{
  inputs,
  den,
  lib,
  ...
}:
{
  imports = [ inputs.den.flakeModule ];

  # Enable homeManager integration for all users by default.
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  # Mutual provider enables the host→user→homeManager pipeline.
  # This allows host aspects to pass config to users via `provides.to-users`
  # and user aspects to forward config to homeManager classes.
  den.ctx.user.includes = [ den._.mutual-provider ];

  den.hosts.x86_64-linux.hinekora = {
    users.espdesign = { };
  }; # framework
  den.hosts.x86_64-linux.kitava = {
    users.espdesign = { };
  }; # desktop
  den.hosts.x86_64-linux.valako = {
    users.espdesign = { };
  }; # cli test
}
