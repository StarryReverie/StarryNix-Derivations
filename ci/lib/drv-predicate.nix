{ lib }:
let
  # Default predicate for filtering derivations that needn't to be built.
  defaultDrvPredicate = # ... -> Bool
    drv: # Derivation
    let
      isBuildable =
        drv:
        let
          licenseFromMeta = drv.meta.license or [ ];
          licenseList = if lib.isList licenseFromMeta then licenseFromMeta else [ licenseFromMeta ];
        in
        !(drv.meta.broken or false) && lib.lists.all (license: license.free or true) licenseList;

      isCacheable = drv: !(drv.preferLocalBuild or false);
    in
    isBuildable drv && isCacheable drv;
in
{
  inherit
    defaultDrvPredicate
    ;
}
