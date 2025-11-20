{
  pkgs ? import <nixpkgs> { },
  lib ? pkgs.lib,
  callPackage ? pkgs.callPackage,
}:
lib.packagesFromDirectoryRecursive {
  inherit callPackage;
  directory = ./pkgs/by-name;
}
