{
  version,
  src,
  cargoHash,
}:
{
  autoPatchelfHook,
  lib,
  libGL,
  libgcc,
  makeWrapper,
  rustPlatform,
  wayland,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  inherit version src cargoHash;
  pname = "nclock-background";

  buildAndTestSubdir = [ "crates/nclock-background" ];

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    libgcc
  ];

  runtimeDependencies = [
    libGL
    wayland
  ];

  meta = {
    mainProgram = "nclock-background";
    platform = lib.platforms.linux;
  };
})
