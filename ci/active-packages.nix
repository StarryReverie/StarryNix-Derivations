{
  system ? builtins.currentSystem,
  lib ? (import ../.).inputs.nixpkgs.lib,
  scope ? import ../pkgs/default.nix { inherit system; },
}:
let
  filterPackages = import ./lib/filter-packages.nix { inherit lib; };

  drvPred =
    drv:
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
    lib.isDerivation drv -> isBuildable drv && isCacheable drv;
in
filterPackages drvPred scope
