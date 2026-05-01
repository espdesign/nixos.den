{
  inputs,
  den,
  lib,
  ...
}:
{
  imports = [ inputs.den.flakeModule ]; # (1)

  den.schema.user.classes = lib.mkDefault [ "homeManager" ]; # (2)

  den.hosts.x86_64-linux.hinekora.users.espdesign = { }; # framework
  den.hosts.x86_64-linux.kitava.users.espdesign = { }; # desktop
}
