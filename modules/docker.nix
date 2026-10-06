{ ... }:
{
  den.aspects.docker =
    {
      user,
      host ? null,
      ...
    }:
    let
      isServer = host ? hostName && host.hostName == "valako";
    in
    {
      nixos =
        { ... }:
        {
          # enable docker
          virtualisation.docker = {
            enable = true;
            daemon.settings = {
              "log-driver" = "json-file";
              "log-opts" = {
                "max-size" = "10m";
                "max-file" = "3";
              };
              "live-restore" = true;
              "userland-proxy" = false;
            };
          };

          users.extraGroups.docker.members = if isServer then [ ] else [ user.userName ];
        };

      homeManager =
        { ... }:
        {
        };
    };
}
