{ ... }:
{
  den.aspects.homelab-compose = {
    homeManager =
      { ... }:
      {
        home.file."docker-compose.yml".text = ''
          services:
            hello-world:
              image: hello-world
        '';
      };
  };
}
