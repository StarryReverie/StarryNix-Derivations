{
  pkgs ? import ((import ../.).inputs.nixpkgs) { },
  lib ? pkgs.lib,
}:
lib.makeScope pkgs.newScope (self: {
  kvlibadwaita = self.callPackage ./kvlibadwaita/package.nix { };
  orchis-kde = self.callPackage ./orchis-kde/package.nix { };
  stinkpot = self.callPackage ./stinkpot/package.nix { };
})
