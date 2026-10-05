{
  callPackage,
  fetchFromGitHub,
  lib,
  makeWrapper,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nclock-screensaver";
  version = "0-unstable-2026-06-13";

  src = fetchFromGitHub {
    owner = "StarryReverie";
    repo = "nclock-background";
    rev = "b4b0a71b95795244f21d9d967c899667916dba99";
    hash = "sha256-EJX/RP1QSqbykrrp6hwu5WYWuc8SQ7Xo18+p6zOp6Jc=";
  };

  cargoHash = "sha256-cLsWniXZWyvzp05vKSedg5w/CLS5EeUzuH/1n26Mse8=";

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

  meta = {
    description = "Screensaver adapter and management process of night clock wallpaper engine";
    homepage = "https://github.com/starryreverie/nclock-background";
    mainProgram = "nclock-screensaver";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.starryreverie ];
  };
})
