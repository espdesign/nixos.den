{ den, ... }:
{
  den.aspects.dev =
    { user, host, ... }:
    {
      includes = [
        den.aspects.cli
        den.aspects.fonts
        den.aspects.docker
      ];

      nixos =
        { ... }:
        {
          # Useful for many dev tools and scripts that expect /usr/bin/env
          # Keep this at system level as it's a global service.
          # services.envfs.enable = true;

          # enable docker
          virtualisation.docker.enable = true;
          users.extraGroups.docker.members = [ user.userName ];

        };

      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            # --- Dev Servers ---
            package-version-server
            dockerfile-language-server
          ];
          programs.vscodium = {
            enable = true;
            profiles.default.extensions =
              with pkgs.vscode-extensions;
              [
                jnoortheen.nix-ide
                dbaeumer.vscode-eslint
                esbenp.prettier-vscode
                astro-build.astro-vscode
                bradlc.vscode-tailwindcss
              ]
              ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
                # Adding extensions NOT in nixpkgs:
                # 1. Find the extension on VS Code Marketplace (e.g., https://marketplace.visualstudio.com/items?itemName=PublisherName.extension-name)
                # 2. Note the publisher name and extension name from the URL
                # 3. Get the latest version number from the page
                # 4. Run: nix store prefetch-file https://marketplace.visualstudio.com/_apis/public/gallery/publishers/<Publisher>/vsextensions/<extension>/<version>/vspackage
                # 5. Add to extensionsFromVscodeMarketplace below with the sha256 hash
                {
                  name = "theme-monokai-pro-vscode";
                  publisher = "monokai";
                  version = "2.0.13";
                  sha256 = "5bKwVzDfZoSipR04tPDx9jbKhYsSsa3z6Ei9E2jhudo=";
                }
              ];
            profiles.default.userSettings = {
              # Typeface & Font Settings
              "editor.fontFamily" = "'JetBrainsMono NF', 'JetBrains Mono', 'monospace', monospace";
              "editor.fontLigatures" = false;
              "editor.fontSize" = if host.hostName == "hinekora" then 16 else 14;
              "terminal.integrated.fontFamily" = "'JetBrainsMono NF'";

              # Line Rulers (Good for maintaining code style/max line lengths)
              "editor.rulers" = [
                80
                120
              ];

              # General UI Customization
              "workbench.colorTheme" = "Monokai Pro";
              "workbench.iconTheme" = "Monokai Pro Icons";

              "editor.formatOnSave" = true;
              "editor.minimap.enabled" = false;
              "explorer.confirmDelete" = false;

              # Nix-specific IDE settings
              "nix.enableLanguageServer" = true;
              "nix.serverPath" = "nixd";
              "nix.serverSettings" = {
                "nixd" = {
                  formatting = {
                    command = [ "nixfmt" ];
                  };
                  options = {
                    nixos = {
                      expr =
                        ''(builtins.getFlake "''
                        + "\${workspaceFolder}"
                        + ''").nixosConfigurations.${host.hostName}.options'';
                    };
                    home-manager = {
                      expr =
                        ''(builtins.getFlake "''
                        + "\${workspaceFolder}"
                        + ''").nixosConfigurations.${host.hostName}.options.home-manager.users.type.getSubOptions []'';
                    };

                  };
                };
              };

            };
          };
          #enable gh with credential helper
          programs.gh = {
            enable = true;
            gitCredentialHelper = {
              enable = true;
            };
          };
        };
    };
}
