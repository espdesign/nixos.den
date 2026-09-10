{
  den,
  ...
}:
{
  den.aspects.jake = {
    includes = [
      den.provides.define-user
      (den.provides.user-shell "zsh")
    ];
    nixos =
      { ... }:
      {
        users.users.jake = {
          initialHashedPassword = "$6$nswNImVPvYzggm7T$sWRM8e0fWMWs007Y8QlH10dysg5/ILPms.4yJ.sUjBq93o5.h7.7GkVmzkpoLQlqrkdugWixAnchrN4UNkRaS.";
        };
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.google-chrome
        ];
      };
  };
}