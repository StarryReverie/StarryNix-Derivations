{
  appstream,
  autoPatchelfHook,
  dbus,
  desktop-file-utils,
  fetchFromGitHub,
  fontconfig,
  lib,
  libGL,
  libgcc,
  libx11,
  libxcb,
  libxcursor,
  libxkbcommon,
  pkg-config,
  python3,
  rustPlatform,
  stdenv,
  updateUtils,
  wayland,
  xinput,
  xvfb,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "flectar-mail";
  version = "0.1.0-alpha.7";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "flectar";
    repo = "mail";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xdjpjFHOKAkLHExbXfssWYz8knRRrAy9rQEErgrN8d4=";
  };

  cargoHash = "sha256-WjEWWxOcGbuWmW+hv4d6DtP6T0Ly6+PooqO48zovU+Y=";

  nativeBuildInputs = [
    appstream
    desktop-file-utils
    pkg-config
    python3
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = [
    dbus
    libgcc
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    fontconfig
  ];

  runtimeDependencies = lib.optionals stdenv.hostPlatform.isLinux [
    libGL
    libx11
    libxcb
    libxcursor
    libxkbcommon
    wayland
    xinput
    xvfb
  ];

  doCheck = false;

  passthru.updateScript =
    let
      baseUpdater = updateUtils.updateAuto {
        attrPath = [ "flectar-mail" ];
      };
    in
    lib.pipe baseUpdater [
      updateUtils.withFormatter
      updateUtils.withGitCommit
    ];

  meta = {
    description = "Lightweight, native client for email, calendars, and contacts";
    homepage = "http://flectar.com/mail/";
    changelog = "https://github.com/flectar/mail/releases/tag/v${finalAttrs.version}";
    mainProgram = "flectar-mail";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = [ lib.maintainers.starryreverie ];
  };
})
