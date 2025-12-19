{
  stdenvNoCC,
  fetchFromGitHub,
  lx-music-desktop,
  makeDesktopItem,
  symlinkJoin,
  copyDesktopItems,
}:
let
  extraItems = stdenvNoCC.mkDerivation {
    name = "lx-music-desktop-extra-items";

    src = fetchFromGitHub {
      owner = "lyswhut";
      repo = "lx-music-desktop";
      tag = "v2.12.0";
      hash = "sha256-g4QVpymzoRKIq70aRLXGFmUmIpSiXIZThrp8fumBKTQ=";
    };

    nativeBuildInputs = [
      copyDesktopItems
    ];

    desktopItems = [
      (makeDesktopItem {
        name = "lx-music-desktop";
        desktopName = "LX Music Desktop";
        exec = "lx-music-desktop";
        icon = "lx-music-desktop";
        terminal = false;
        mimeTypes = [ "x-scheme-handler/lxmusic" ];
        categories = [ "Utility" "AudioVideo" "Audio" "Player" "Music" ];
        startupNotify = false;
      })
    ];

    postInstall = ''
      for size in 16 32 48 64 128 256 512; do
        install -D -m 444 \
          resources/icons/"$size"x"$size".png \
          $out/share/icons/hicolor/"$size"x"$size"/apps/lx-music-desktop.png
      done
    '';
  };
in
symlinkJoin {
  name = "lx-music";

  paths = [
    lx-music-desktop
    extraItems
  ];
}
