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
  buildJobPackages = # AttrSet
    evalJobSet defaultDrvPredicate (path: lib.id) scope;

  # Update scripts of all packages, if exist.
  updateScripts = # [AttrSet]
    evalJobList (drv: lib.attrsets.hasAttr "updateScript" drv) (path: value: {
      attr = lib.strings.concatStringsSep "." path;
      attrPath = path;
      script = value;
    }) scope;
in
{
  inherit
    buildJobPackages
    updateScripts
    ;
}
