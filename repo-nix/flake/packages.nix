{
  lib,
  flake-parts-lib,
  inputs,
  ...
}:
{
  perSystem =
    { config, pkgs, ... }:
    {
      packages = lib.attrsets.filterAttrs (_: lib.isDerivation) config.legacyPackages;

      legacyPackages = import ../../pkgs { inherit pkgs; };
    };
}
