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
    ];
    nixos =
      { pkgs, ... }:
      {
        imports = [ ../_nixos/kitava-desktop.nix ];
        environment.systemPackages = with pkgs; [
          firefox
          vscodium
          #git
          gh
          opencode
          gemini-cli
        ];
        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
  };
}
