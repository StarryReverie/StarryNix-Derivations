{
  cabal2nix,
  curl,
  fetchurl,
  haskell,
  haskellPackages,
  hpack,
  jq,
  lib,
  updateUtils,
}:
let
  sources = builtins.fromJSON (builtins.readFile ./sources.json);

  drv = haskellPackages.callPackage ./generated.nix {
    src = fetchurl {
      inherit (sources) hash;
      url = "https://github.com/StarryReverie/DrvGraph/archive/${sources.rev}.tar.gz";
    };
  };
in
haskell.lib.justStaticExecutables (
  drv.overrideAttrs (old: {
    __structuredAttrs = true;
    strictDeps = true;

    meta = old.meta // {
      description = "Traverse and analyze the dependency graph of a Nix package";
      homepage = "https://github.com/StarryReverie/DrvGraph";
      license = lib.licenses.gpl3Plus;
      platforms = lib.platforms.unix;
      maintainers = [ lib.maintainers.starryreverie ];
    };

    passthru = (old.passthru or { }) // {
      updateScript =
        let
          baseUpdater = updateUtils.updateCustom {
            attrPath = [ "drvgraph" ];
            scriptFile = ./update.sh;
            extraRuntimeInputs = [
              cabal2nix
              hpack
              jq
              curl
            ];
          };
        in
        lib.pipe baseUpdater [
          updateUtils.withFormatter
          updateUtils.withGitCommit
        ];
    };
  })
)
