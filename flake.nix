{
  description = "My nixos config using denful/den";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    den.url = "github:denful/den";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    let
      flakeOutputs =
        (inputs.nixpkgs.lib.evalModules {
          modules = [ (inputs.import-tree ./modules) ];
          specialArgs.inputs = inputs;
        }).config.flake;
    in
    builtins.removeAttrs flakeOutputs [
      "denful"
      "resolved"
      "id_hash"
      "collisionPolicy"
    ];
}
