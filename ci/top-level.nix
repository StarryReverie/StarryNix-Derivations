{
  system ? builtins.currentSystem,
  lib ? (import ../.).inputs.nixpkgs.lib,
  scope ? import ../pkgs/default.nix { inherit system; },
}:
let
  inherit (import ./lib/drv-predicate.nix { inherit lib; })
    defaultDrvPredicate
    ;
  inherit (import ./lib/eval-jobs.nix { inherit lib; })
    evalJobSet
    evalJobList
    ;
in
let
  # Package set of all buildable derivations.
  active = # AttrSet
    evalJobSet defaultDrvPredicate (path: lib.id) scope;
in
{
  inherit
    active
    ;
}
