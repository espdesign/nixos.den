{ ... }:
{
  den.aspects.docker =
    { user, ... }:
    {
      nixos =
        { ... }:
        {
          # enable docker
          virtualisation.docker.enable = true;
          users.extraGroups.docker.members = [ user.userName ];

        };

      homeManager =
        { ... }:
        {
        };
    };
}
