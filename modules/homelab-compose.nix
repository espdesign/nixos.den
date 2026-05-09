{ ... }:
{
  den.aspects.homelab-compose = {
    homeManager =
      { ... }:
      {
        home.file."docker-compose.yml".text = ''
          version: "3.9"
          services:
            hello-world:
              image: hello-world
        '';
      };
  };
}
