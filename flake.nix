{
  description = "StarryNix-Derivations";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts/main";
    };
  };

  outputs =
    { self, flake-parts, ... }@inputs: flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        { inputs', pkgs, ... }:
        {
          devShells.default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              nil
              nixfmt-rfc-style
            ];
          };

          formatter = pkgs.nixfmt-tree;
        };
    };
}
