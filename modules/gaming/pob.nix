{ den, ... }:
{
  # We extend the gaming aspect by providing a 'pob' sub-aspect
  den.aspects.gaming.provides.pob = {
    nixos =
      { pkgs, ... }:
      {
        nixpkgs.overlays = [
          (final: prev: {
            rusty-path-of-building = prev.rusty-path-of-building.overrideAttrs (oldAttrs: {
              nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ final.imagemagick ];
              postInstall = (oldAttrs.postInstall or "") + ''
                # Generate the Red PoE 2 icon using your v10 levels
                magick assets/icon.png -modulate 100,120,80 path-of-building-2.png
                install -Dm444 path-of-building-2.png $out/share/icons/hicolor/256x256/apps/path-of-building-2.png
              '';
              desktopItems = [
                (final.makeDesktopItem {
                  name = "rusty-path-of-building-1";
                  desktopName = "Path of Building";
                  comment = "Offline build planner for Path of Exile";
                  exec = "rusty-path-of-building poe1";
                  terminal = false;
                  type = "Application";
                  icon = "path-of-building";
                  categories = [ "Game" ];
                  keywords = [
                    "poe"
                    "pob"
                    "pobc"
                    "path"
                    "exile"
                  ];
                })
                (final.makeDesktopItem {
                  name = "rusty-path-of-building-2";
                  desktopName = "Path of Building 2";
                  comment = "Offline build planner for Path of Exile 2";
                  exec = "rusty-path-of-building poe2";
                  terminal = false;
                  type = "Application";
                  icon = "path-of-building-2";
                  categories = [ "Game" ];
                  keywords = [
                    "poe"
                    "pob"
                    "pobc"
                    "path"
                    "exile"
                  ];
                })
              ];
            });
          })
        ];
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.rusty-path-of-building ];
      };
  };
}
