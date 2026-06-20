{ den, ... }:
{
  den.aspects.rustdesk = {
    includes = [
      (den.provides.unfree [
        "rustdesk"
        "libsciter"
      ])
    ];

    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        rustdesk
      ];
    };
  };
}
