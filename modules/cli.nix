{ ... }:
{
  den.aspects.cli =
    { user, host, ... }:
    {
      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            opencode
            gemini-cli
            devenv
            # --- Common Utils ---
            ripgrep
            fd
            jq
            yq-go
            tree
            wget
            curl
          ];
          programs.neovim = {
            enable = true;
            vimAlias = true;
            viAlias = true;
            withRuby = false;
            withPython3 = false;
          };

          programs.zsh = {
            enable = true;
            enableCompletion = true;
            autosuggestion.enable = true;
            syntaxHighlighting.enable = true;

            shellAliases = {
              c = "clear";

              # 2. Modern Replacements
              cat = "bat"; # bat is a colorful 'cat'
              grep = "rg"; # ripgrep is faster than grep
              ls = "eza --icons"; # eza is a better 'ls'
              ll = "eza -l --icons --git -a";
              lt = "eza --tree --level=2 --icons";

              # 3. Nix Shortcuts
              nrb = "sudo nixos-rebuild build --flake .";
              nrs = "sudo nixos-rebuild switch --flake .";
              # 'flake check' is great before rebuilding
              nfc = "nix flake check";
              code = "codium";
              nix-edit = "code ~/git/nixos.den";
              nix-apply = "sudo nixos-rebuild switch --flake ~/git/nixos.den#${host.hostName}";
              nix-update = "git -C ~/git/nixos.den pull && nix-apply";
            };

            # Keep your existing env vars
            # enable devenv auto activation with eval.
            initContent = ''
              eval "$(devenv hook zsh)"
              export NIX_PATH=nixpkgs=channel:nixos-unstable
              export NIX_LOG=info
              export TERMINAL=ghostty
              export EDITOR=nvim
              export DIRENV_LOG_FORMAT=""
              if [ -e /home/${user.userName}/.nix-profile/etc/profile.d/nix.sh ]; then . /home/${user.userName}/.nix-profile/etc/profile.d/nix.sh; fi
            '';
          };

          # 1. Starship Prompt (The "Looks Better" part)
          programs.starship = {
            enable = true;
            enableZshIntegration = true;
            settings = {
              add_newline = true;
              aws.disabled = true;
              gcloud.disabled = true;
              line_break.disabled = false;
            };
          };

          # 2. Zoxide (The "Smarter cd" part)
          programs.zoxide = {
            enable = true;
            enableZshIntegration = true;
            options = [
              "--cmd"
              "cd"
            ]; # Replace 'cd' with 'z' automatically
          };

          # 3. Eza (The "Better ls" part)
          programs.eza = {
            enable = true;
            enableZshIntegration = true;
            icons = "auto";
            git = true;
          };

          # 4. FZF (Fuzzy Finder - Ctrl+R to search history)
          programs.fzf = {
            enable = true;
            enableZshIntegration = true;
          };

          # 5. Bat (Better cat)
          programs.bat = {
            enable = true;
            config = {
              theme = "TwoDark";
            };
          };

          # 6. Direnv (Automates 'nix develop')
          programs.direnv = {
            enable = true;
            enableZshIntegration = true;
            nix-direnv.enable = true;
            # Prevent direnv shoowing all env variables on load
            config.global.hide_env_diff = true;
          };
        };
    };
}
