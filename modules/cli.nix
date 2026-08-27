{ den, ... }:
{
  den.aspects.cli =
    { user, host, ... }:
    {
      includes = [
        (den.provides.unfree [
          "claude-code"
        ])
      ];

      homeManager =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            opencode
            claude-code
            devenv
            # --- Common Utils ---
            ripgrep
            fd
            jq
            yq-go
            tree
            wget
            curl
            btop
            # --- Treesitter Dependencies ---
            tree-sitter
            gcc
          ];
          programs.neovim = {
            enable = true;
            vimAlias = true;
            viAlias = true;
            withRuby = false;
            withPython3 = false;
          };

          # Symlink Neovim init.lua selectively, leaving ~/.config/nvim writable
          xdg.configFile."nvim/init.lua".source = ./assets/nvim/init.lua;

          programs.zsh = {
            enable = true;
            enableCompletion = true;
            autosuggestion.enable = true;
            syntaxHighlighting.enable = true;

            completionInit = ''
              autoload -U compinit
              if [[ -n ~/.zcompdump(N.mh-24) ]]; then
                compinit -C
              else
                compinit
              fi
              { zcompile -R ~/.zcompdump.zwc ~/.zcompdump } &!
            '';

            shellAliases = {
              c = "clear";

              # 2. Modern Replacements
              cat = "bat"; # bat is a colorful 'cat'
              grep = "rg"; # ripgrep is faster than grep
              top = "btop";
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
              export NIX_PATH=nixpkgs=channel:nixos-unstable
              export NIX_LOG=info
              export TERMINAL=ghostty
              export EDITOR=nvim
              export DIRENV_LOG_FORMAT=""
              if [ -e /home/${user.userName}/.nix-profile/etc/profile.d/nix.sh ]; then . /home/${user.userName}/.nix-profile/etc/profile.d/nix.sh; fi

              # Eval caching helper for fast zsh startup
              _eval_cache() {
                local name="$1"
                shift
                local cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/eval-cache"
                local cache_file="$cache_dir/$name.zsh"
                local bin_real="''${commands[$1]:A}"
                local first_line=""
                [[ -f "$cache_file" ]] && read -r first_line < "$cache_file"
                if [[ ! -s "$cache_file" || ( -n "$bin_real" && "$first_line" != "# BIN: $bin_real" ) ]]; then
                  mkdir -p "$cache_dir"
                  echo "# BIN: $bin_real" > "$cache_file"
                  "$@" >> "$cache_file" 2>/dev/null
                fi
                source "$cache_file"
              }

              _eval_cache devenv devenv hook zsh
              _eval_cache starship starship init zsh
              _eval_cache direnv direnv hook zsh
              _eval_cache zoxide zoxide init zsh --cmd cd
              _eval_cache fzf fzf --zsh
            '';
          };

          # 1. Starship Prompt (The "Looks Better" part)
          programs.starship = {
            enable = true;
            enableZshIntegration = false;
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
            enableZshIntegration = false;
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
            enableZshIntegration = false;
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
            enableZshIntegration = false;
            nix-direnv.enable = true;
            # Prevent direnv shoowing all env variables on load
            config.global.hide_env_diff = true;
          };
        };
    };
}
