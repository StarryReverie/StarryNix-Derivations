{
  lib,
  flake-parts-lib,
  inputs,
  ...
}:
{
  imports = [
    (flake-parts-lib.mkTransposedPerSystemModule {
      name = "ciPackages";
      file = ./packages.nix;
      option = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        description = "Package set that will be built by CIs";
        default = { };
        example = { };
      };
    })
  ];

  perSystem =
    { config, pkgs, ... }:
    {
      packages = lib.attrsets.filterAttrs (_: lib.isDerivation) config.legacyPackages;

      legacyPackages = import ../../pkgs { inherit pkgs; };

      ciPackages = {
        all = import ../../ci/all-packages.nix {
          inherit lib;
          scope = config.legacyPackages;
        };

        active = import ../../ci/active-packages.nix {
          inherit lib;
          scope = config.legacyPackages;
        };
      };
    };
}
