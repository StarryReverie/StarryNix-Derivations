{
  cava,
  desktop-file-utils,
  fetchFromGitHub,
  gobject-introspection,
  gst_all_1,
  gtk4,
  lib,
  libadwaita,
  ninja,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:

let
  pname = "cavasik";
  version = "3.2.0";
in
python3Packages.buildPythonApplication {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "TheWisker";
    repo = "Cavasik";
    tag = "v${version}";
    hash = "sha256-O8rFtqzmDktXKF3219RAo1yxqjfPm1qkHhAyoT7N8AU=";
  };

  pyproject = false;

  build-system = with python3Packages; [
    meson
    ninja
  ];

  dependencies = with python3Packages; [
    pycairo
    pydbus
    pygobject3
  ];

  nativeBuildInputs = [
    desktop-file-utils
    gobject-introspection
    gst_all_1.gstreamer
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
  ];

  postPatch = ''
    substituteInPlace src/cava.py \
      --replace-fail '"cava"' '"${lib.getExe cava}"'
  '';

  buildPhase = ''
    runHook preBuild

    mkdir -p build
    meson setup build --prefix=$out
    meson compile -C build

    runHook postBuild
  '';

  checkPhase = ''
    runHook preCheck

    meson test -C build --print-errorlog

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    meson install -C build

    runHook postInstall
  '';

  postFixup = ''
    substituteInPlace $out/share/applications/io.github.TheWisker.Cavasik.desktop \
      --replace-fail "Exec=cavasik" "Exec=$out/bin/cavasik"
  '';

  meta = {
    description = "Audio visualizer based on CAVA with extended capabilities";
    mainProgram = "cavasik";
    homepage = "https://github.com/TheWisker/Cavasik";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
