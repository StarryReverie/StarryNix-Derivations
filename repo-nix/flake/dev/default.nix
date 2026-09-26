{ lib, inputs, ... }:
{
  imports = [
    ./devshells.nix
  ];

  perSystem =
    { pkgs, ... }:
    {
      _module.args.pkgsDev = pkgs;
    };

  flake.inputsDev = inputs;
}
