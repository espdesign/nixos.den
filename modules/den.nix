{
  inputs,
  den,
  lib,
  ...
}:
{
  imports = [ inputs.den.flakeModule ];

  den.schema.user.classes = lib.mkDefault [ "homeManager" ]; # enable homeManager integration for all users by default.
  den.ctx.user.includes = [ den._.mutual-provider ];

  den.hosts.x86_64-linux.hinekora = {
    users.espdesign = { };
  }; # framework
  den.hosts.x86_64-linux.kitava = {
    users.espdesign = { };
  }; # desktop
  den.hosts.x86_64-linux.test-cli = {
    users.espdesign = { };
  }; # cli test
}
