{ den, ... }:
{
  den.aspects.gaming = {
    includes = [
      (den.provides.unfree [
        "steam"
        "steam-unwrapped"
      ])
    ];

    nixos =
      { pkgs, ... }:
      {
        # --- Steam configuration ---
        programs.steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          localNetworkGameTransfers.openFirewall = true;
        };

        # --- GameMode ---
        programs.gamemode.enable = true;
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          protonup-qt
          mangohud
        ];
      };
  };
}
