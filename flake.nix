{
  inputs.nixpkgs = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.darwin = "github:nix-darwin/nix-darwin";
  inputs.import-tree.url = "github:vic/import-tree";
  inputs.den.url = "github:vic/den";

  outputs = inputs:
   (inputs.nixpkgs.lib.evalModules {
     modules = [ (inputs.import-tree ./modules) ];
     specialArgs.inputs = inputs;
   }).config.flake;
}
