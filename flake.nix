{
  description = "StarryNix-Derivations";

  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts/main";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    systems = {
      url = "github:nix-systems/default/main";
    };
  };

  outputs =
    { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [
        inputs.flake-parts.flakeModules.partitions
        ./repo-nix/flake
      ];

      _module.args = {
        flakeRoot = ./.;
      };

      partitions = {
        dev = {
          module = ./repo-nix/flake/dev;
          extraInputsFlake = ./repo-nix/flake/dev;
        };
      };

      partitionedAttrs = {
        checks = "dev";
        devShells = "dev";
        formatter = "dev";
        inputsDev = "dev";
      };
    };
}
