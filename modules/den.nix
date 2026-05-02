{
  inputs,
  den,
  lib,
  ...
}:
{
  imports = [ inputs.den.flakeModule ];

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  den.hosts.x86_64-linux.hinekora = {
    users.espdesign = { classes = [ "homeManager" ]; };
  }; # framework
  den.hosts.x86_64-linux.kitava = {
    users.espdesign = { classes = [ "homeManager" ]; };
  }; # desktop
}
