{
  system ? builtins.currentSystem,
  lib ? (import ../.).inputs.nixpkgs.lib,
  scope ? import ../pkgs/default.nix { inherit system; },
}:
let
  filterPackages = import ./lib/filter-packages.nix { inherit lib; };
in
filterPackages (lib.const true) scope
