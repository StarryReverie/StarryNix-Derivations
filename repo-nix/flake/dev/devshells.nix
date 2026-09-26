{ lib, inputs, ... }:
{
  perSystem =
    { pkgsDev, ... }:
    {
      devShells.default = pkgsDev.mkShellNoCC {
        packages = [
          pkgsDev.nixfmt
          pkgsDev.treefmt
        ];
      };
    };
}
