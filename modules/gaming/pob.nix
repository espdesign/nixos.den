{ den, ... }:
{
  den.aspects.pob = {
    nixos =
      { pkgs, ... }:
      {
        # nixpkgs.overlays = [
        #   (final: prev: {
        #     rusty-path-of-building =
        #       let
        #         pob1-src = prev.fetchzip {
        #           url = "https://github.com/PathOfBuildingCommunity/PathOfBuilding/archive/refs/tags/v2.65.0.tar.gz";
        #           sha256 = "19lzxiw2xb509i3mikjn2303vd592l8wl9jbz7hbwzi2p1xzvnll";
        #         };
        #         pob2-src = prev.fetchzip {
        #           url = "https://github.com/PathOfBuildingCommunity/PathOfBuilding-PoE2/archive/refs/tags/v0.15.0.tar.gz";
        #           sha256 = "1qj5lqsd32vpk8dsa4mrzi8dhzflg113i2qnwq9v3dnasw3pn3id";
        #         };
        #         updateCheckLua = prev.fetchurl {
        #           url = "https://raw.githubusercontent.com/meehl/rusty-pob-manifest/main/UpdateCheck.lua";
        #           sha256 = "17wj8v9gc42rhjacsr16s0xm38jm0s0vqjb7h3shrgzfzq0kip6s";
        #         };
        #         updateCheckSha1 = prev.fetchurl {
        #           url = "https://raw.githubusercontent.com/meehl/rusty-pob-manifest/main/UpdateCheck.lua.sha1";
        #           sha256 = "169kp6d76bj9mryr96zbxspkf07zyhycgihzh8d5ixy9fi4vrv7x";
        #         };

        #         buildAssets =
        #           src:
        #           prev.stdenv.mkDerivation {
        #             name = "pob-assets";
        #             inherit src;
        #             dontBuild = true;
        #             installPhase = ''
        #               mkdir -p $out
        #               cp manifest.xml help.txt changelog.txt LICENSE.md $out/
        #               cp -r src/* $out/
        #               mkdir -p $out/lua
        #               cp -r runtime/lua/* $out/lua/
        #               cp ${updateCheckLua} $out/UpdateCheck.lua

        #               sha=$(cat ${updateCheckSha1} | awk '{print $1}')
        #               sed -i -E "s/name=\"UpdateCheck.lua\" sha1=\"[0-9A-Za-z]+\"/name=\"UpdateCheck.lua\" sha1=\"$sha\"/" $out/manifest.xml
        #               sed -i -E "s|<Version|<Version branch=\"master\" platform=\"linux\"|" $out/manifest.xml

        #               printf "%s" "${prev.rusty-path-of-building.version}" > $out/rpob.version
        #             '';
        #           };

        #         pob1-assets = buildAssets pob1-src;
        #         pob2-assets = buildAssets pob2-src;
        #       in
        #       prev.rusty-path-of-building.overrideAttrs (old: {
        #         postFixup = old.postFixup + ''
        #           # Rename the wrapped binary
        #           mv $out/bin/rusty-path-of-building $out/bin/.rusty-path-of-building-orig

        #           # Create a new wrapper script
        #           cat << 'EOF' > $out/bin/rusty-path-of-building
        #           #!/usr/bin/env bash
        #           set -e

        #           GAME="$1"
        #           if [ "$GAME" = "poe1" ]; then
        #             DATA_DIR="$HOME/.local/share/RustyPathOfBuilding1"
        #             ASSETS="${pob1-assets}"
        #           elif [ "$GAME" = "poe2" ]; then
        #             DATA_DIR="$HOME/.local/share/RustyPathOfBuilding2"
        #             ASSETS="${pob2-assets}"
        #           fi

        #           if [ -n "$DATA_DIR" ] && [ ! -f "$DATA_DIR/rpob.version" ]; then
        #             echo "Initializing Path of Building assets in $DATA_DIR..."
        #             mkdir -p "$DATA_DIR"
        #             cp -r "$ASSETS"/* "$DATA_DIR"/
        #             chmod -R u+w "$DATA_DIR"
        #           fi

        #           exec "$(dirname "$0")/.rusty-path-of-building-orig" "$@"
        #           EOF

        #           chmod +x $out/bin/rusty-path-of-building
        #         '';
        #       });
        #   })
        # ];
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.rusty-path-of-building ];
      };
  };
}
