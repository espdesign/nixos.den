{
  description = "My nixos config suing den";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # darwin.url = "github:nix-darwin/nix-darwin";
    home-manager.url = "github:nix-community/home-manager";
    import-tree.url = "github:vic/import-tree";
    den.url = "github:vic/den";
  };

  outputs = inputs:
   (inputs.nixpkgs.lib.evalModules {
     modules = [ (inputs.import-tree ./modules) ];
     specialArgs.inputs = inputs;
   }).config.flake;
}
