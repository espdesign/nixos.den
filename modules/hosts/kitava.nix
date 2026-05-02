# kitava is my desktop with nvidia 3070ti
{
  inputs,
  den,
  lib,
  ...
}:
{
  den.aspects.kitava = { host, ... }: {
    includes = [
      den.provides.hostname
      den.aspects.gaming
      den.aspects.gui
      den.aspects.cli
    ];
    nixos =
      { pkgs, ... }:
      {
        imports = [ ../_nixos/kitava-desktop.nix ];
        environment.systemPackages = with pkgs; [ ];
        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
  };
}
