{
  inputs,
  den,
  lib,
  ...
}:
{
  imports = [ inputs.den.flakeModule ]; # (1)

  den.schema.user.classes = lib.mkDefault [ "homeManager" ]; # (2)

  den.hosts.x86_64-linux.hinekora.users.espdesign = { }; # framework
  den.hosts.x86_64-linux.kitava.users.espdesign = { }; # desktop

  # den.aspects.hinekora = { # (6)
  #   includes = [ den.provides.hostname ]; # (7)/home/espdesign/git/nixos.config/hosts/kitava-desktop/hardware.nix
  #   nixos = { pkgs, ... }: {
  #     imports = [ ./_nixos/hinekora-framework.nix ]; # (8)
  #     environment.systemPackages = with pkgs; [ firefox vscodium git gh opencode];
  #     nix.settings.experimental-features = ["nix-command" "flakes"];
  #   };
  # };

  # den.aspects.espdesign = { # (9)
  #   includes = [ den.provides.define-user den.provides.primary-user (den.provides.user-shell "fish")]; # (10)
  #   homeManager = { pkgs, ... }: {
  #     home.packages = [ pkgs.vim ];
  #   };
  # };
}
