{
  autoPatchelfHook,
  aws-lc,
  electron_45,
  lib,
  libpulseaudio,
  lld,
  makeWrapper,
  pipewire,
  pkg-config,
  pnpmConfigHook,
  rustPlatform,
  sable-frontend,
  sqlite,
  stdenv,

  commandLineArgs ? "",
}:
let
  electron = electron_45;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sable-desktop";
  inherit (sable-frontend) version src;

  __structuredAttrs = true;
  strictDeps = true;

  inherit (sable-frontend) cargoDeps pnpmDeps;

  nativeBuildInputs = [
    (pnpmConfigHook.override { pnpm = sable-frontend.passthru.pnpm; })
    sable-frontend.passthru.nodejs
    sable-frontend.passthru.pnpm

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

  env = (sable-frontend.passthru.env or { }) // {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  };

  buildPhase = ''
    runHook preBuild

    cp -r ${sable-frontend} dist

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

    # Install `out`
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
    electron = electron_45;

    frontend = sable-frontend;
  };

  meta = {
    description = "Almost stable Matrix client (Desktop)";
    homepage = "https://git.sable.moe/SableClient/sable-next";
    changelog = "https://git.sable.moe/SableClient/sable-next/src/tag/${finalAttrs.version}/CHANGELOG.md";
    mainProgram = "sable";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.all;
    maintainers = [ lib.maintainers.starryreverie ];
  };
})
