{
  callPackage,
  fetchFromGitHub,
  lib,
  makeWrapper,
  rustPlatform,
  updateUtils,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nclock-screensaver";
  version = "0-unstable-2026-10-07";

  src = fetchFromGitHub {
    owner = "StarryReverie";
    repo = "nclock-background";
    rev = "3cc77cf69255e1599481e4219318b78514b2751f";
    hash = "sha256-cz688V0yrvKi/1zS123xgEoZ2HDTPwr1eyAOhnaIYNQ=";
  };

  cargoHash = "sha256-adkK11EWRyM8CwzTFQnn0n3jMPdYiYBSWcEYQ5TNSKw=";

  buildAndTestSubdir = [ "crates/nclock-screensaver" ];

  nativeBuildInputs = [
    makeWrapper
  ];

  postInstall =
    let
      background = callPackage (import ./background.nix {
        inherit (finalAttrs) version src cargoHash;
      }) { };
    in
    ''
      wrapProgram $out/bin/nclock-screensaver \
        --prefix PATH : ${lib.makeBinPath [ background ]}
    '';

  passthru.updateScript =
    let
      baseUpdater = updateUtils.updateAuto {
        attrPath = [ "nclock-screensaver" ];
        branch = "main";
      };
    in
    lib.pipe baseUpdater [
      updateUtils.withFormatter
      updateUtils.withGitCommit
    ];

  meta = {
    description = "Screensaver adapter and management process of night clock wallpaper engine";
    homepage = "https://github.com/starryreverie/nclock-background";
    mainProgram = "nclock-screensaver";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.starryreverie ];
  };
})
