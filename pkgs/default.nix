{
  system ? builtins.currentSystem,
  pkgs ? (import ../.).inputs.nixpkgs.legacyPackages.${system},
}:
let
  lib = pkgs.lib;
in
lib.makeScope pkgs.newScope (self: {
  drvgraph = self.callPackage ./drvgraph/package.nix { };
  kvlibadwaita = self.callPackage ./kvlibadwaita/package.nix { };
  orchis-kde = self.callPackage ./orchis-kde/package.nix { };
  stinkpot = self.callPackage ./stinkpot/package.nix { };
})
