{
  lib,
  flake-parts-lib,
  inputs,
  ...
}:
{
  imports = [
    (flake-parts-lib.mkTransposedPerSystemModule {
      name = "ciMetadata";
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
      ciMetadata = import ../ci/top-level.nix {
        inherit lib;
        scope = config.legacyPackages;
      };
    };
}
