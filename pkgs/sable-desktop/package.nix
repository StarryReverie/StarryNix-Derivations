{
  autoPatchelfHook,
  aws-lc,
  binaryen,
  buildWasmBindgenCli,
  electron_45,
  fetchCrate,
  fetchFromForgejo,
  fetchPnpmDeps,
  lib,
  libpulseaudio,
  lld,
  llvmPackages,
  makeWrapper,
  nodejs_26,
  pipewire,
  pkg-config,
  pnpmConfigHook,
  pnpm_12,
  rustPlatform,
  sqlite,
  stdenv,

  commandLineArgs ? "",
}:
let
  electron = electron_45;
  nodejs = nodejs_26;
  pnpm = pnpm_12;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sable-desktop";
  version = "2.3.9";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromForgejo {
    domain = "git.sable.moe";
    owner = "SableClient";
    repo = "sable-next";
    rev = "v${finalAttrs.version}";
    hash = "sha256-89oe2t8POjwSDz5T5onlDYgyfaPDWzf6KvLLi8uCFUM=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-hhTjjNlAzGmniTa7r15LXaZicgKEEyLcuKkJlNsLCl0=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-LtOqaSAVBItWnQmnOZUXSakaIKkZnZnvqN86bhq3FjQ=";
  };

  nativeBuildInputs = [
    (pnpmConfigHook.override { inherit pnpm; })
    binaryen
    finalAttrs.passthru.wasm-bindgen-cli
    nodejs
    pnpm

    lld
    pkg-config
    rustPlatform.bindgenHook
    rustPlatform.cargoSetupHook
    rustPlatform.rust.cargo
    rustPlatform.rust.rustc

    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    aws-lc
    libpulseaudio
    pipewire
    sqlite
    stdenv.cc.cc.lib
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    SABLE_BUILD_FLAVOR = "stable";
    SABLE_FOSS = "1";
    VERSION = finalAttrs.version;
    VITE_APP_VERSION = finalAttrs.version;
    VITE_BUILD_HASH = finalAttrs.src.rev;

    AR_wasm32_unknown_unknown = lib.getExe' llvmPackages.bintools-unwrapped "llvm-ar";
    CC_wasm32_unknown_unknown = lib.getExe llvmPackages.clang-unwrapped;
  };

  buildPhase = ''
    runHook preBuild

    pnpm build

    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist
    pnpm --dir electron package --linux --dir \
      -c.electronDist=$PWD/electron-dist \
      -c.electronVersion=${electron.version} \
      -c.extraMetadata.autoUpdate=false

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/sable-desktop
    cp -r electron/release/linux*-unpacked/resources/. $out/opt/sable-desktop
    echo nix > $out/opt/sable-desktop/package-type

    makeWrapper ${lib.getExe electron} $out/bin/sable \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --add-flags $out/opt/sable-desktop/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --add-flags ${lib.escapeShellArg commandLineArgs}

    install -Dm644 packaging/flatpak/moe.sable.client.desktop -t $out/share/applications
    for size in 32 64 128 256; do
      install -Dm644 packaging/flatpak/icons/''${size}x''${size}.png \
        $out/share/icons/hicolor/''${size}x''${size}/apps/moe.sable.client.png
    done

    runHook postInstall
  '';

  passthru = {
    wasm-bindgen-cli = buildWasmBindgenCli (
      lib.fix (finalAttrs: {
        src = fetchCrate {
          pname = "wasm-bindgen-cli";
          version = "0.2.130";
          hash = "sha256-9Og1O/6/VC3sc5hBjoIWBErmLW2UHGMsTQO+6+m/dng=";
        };

        cargoDeps = rustPlatform.fetchCargoVendor {
          inherit (finalAttrs.src) pname version;
          inherit (finalAttrs) src;
          hash = "sha256-j81sUf1m5yXU4FJfGj7GV+hdqVCV8mRmNb0QIsMCjqw=";
        };
      })
    );
  };

  meta = {
    description = "Almost stable Matrix client";
    homepage = "https://git.sable.moe/SableClient/sable-next";
    changelog = "https://git.sable.moe/SableClient/sable-next/src/tag/${finalAttrs.version}/CHANGELOG.md";
    mainProgram = "sable";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.starryreverie ];
  };
})
