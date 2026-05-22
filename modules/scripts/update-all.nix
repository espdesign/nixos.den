{ den, ... }:
{
  den.aspects.scripts.provides.update-all =
    { user, host, ... }:
    {
      homeManager =
        { pkgs, lib, ... }:
        let
          hosts = [
            "valako"
            "kitava"
            "hinekora"
          ];
          update-all = pkgs.writeShellApplication {
            name = "update-all-hosts";
            runtimeInputs = with pkgs; [
              git
              openssh
              nixos-rebuild
            ];
            text = ''
              REPO_DIR="$HOME/git/nixos.den"
              CURRENT_HOST="$(hostname)"
              failed=()

              for host in ${lib.concatStringsSep " " hosts}; do
                if [ "$host" = "$CURRENT_HOST" ]; then
                  echo "  Skipping $host (current host)"
                  continue
                fi

                echo ">>> Updating $host"
                cmd="git -C $REPO_DIR fetch origin && git -C $REPO_DIR reset --hard origin/main && sudo nixos-rebuild switch --flake $REPO_DIR#$host"

                if ssh -t "$host" "$cmd"; then
                  echo ">>> $host updated successfully"
                else
                  echo ">>> $host FAILED"
                  failed+=("$host")
                fi
              done

              if [ ''${#failed[@]} -gt 0 ]; then
                echo ">>> Failures: ''${failed[*]}"
              fi

              read -rp ">>> Update $CURRENT_HOST (current host)? [y/N] " answer
              if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
                git -C "$REPO_DIR" fetch origin && \
                git -C "$REPO_DIR" reset --hard origin/main && \
                sudo nixos-rebuild switch --flake "$REPO_DIR#$CURRENT_HOST"
              fi

              if [ ''${#failed[@]} -gt 0 ]; then
                exit 1
              fi

              echo ">>> All hosts updated"
            '';
          };
        in
        {
          home.packages = [ update-all ];
        };
    };
}
