{
  appstream,
  dbus,
  desktop-file-utils,
  fetchFromGitHub,
  fontconfig,
  lib,
  libx11,
  libxcb,
  libxcursor,
  libxkbcommon,
  pkg-config,
  python3,
  rustPlatform,
  updateUtils,
  xinput,
  xvfb,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "flectar";
  version = "0.1.0-alpha.7";

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
  ];

  buildInputs = [
    dbus
    fontconfig
    libx11
    libxcb
    libxcursor
    libxkbcommon
    xinput
    xvfb
  ];

  doCheck = false;

  passthru.updateScript =
    let
      baseUpdater = updateUtils.updateAuto {
        attrPath = [ "flectar" ];
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
    mainProgram = "flectar";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.starryreverie ];
  };
})
