let
  sources = import ./npins; # (1)
  with-inputs = import sources.with-inputs sources { }; # (2)
  outputs = inputs:
    (inputs.nixpkgs.lib.evalModules { # (3)
      modules = [ (inputs.import-tree ./modules) ]; # (4)
      specialArgs.inputs = inputs; # (5)
    }).config.flake; # (6)
in
with-inputs outputs # (7)
