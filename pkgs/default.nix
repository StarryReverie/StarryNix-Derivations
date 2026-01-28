{
  pkgs ? import ((import ../.).inputs.nixpkgs) { },
  lib ? pkgs.lib,
}:
let
  callPackage = lib.customisation.callPackageWith (
    lib.attrsets.mergeAttrsList [
      pkgs
      exportedPackages
    ]
  );

  exportedPackages = import ./by-name/package-set.nix pkgs callPackage;
in
exportedPackages

