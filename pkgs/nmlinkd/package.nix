{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nmlinkd";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "SubZ69";
    repo = "nmlinkd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DllpsAHcyUprEeutR3QdKVxMAzvzIOX7/lqnFLBI1Bs=";
  };

  cargoHash = "sha256-5prZ1Jm/7QIQVB7XHV+2USvACz69fcKm0w0DeqioTxk=";

  meta = {
    description = "Native GNOME/KDE network indicator for systemd-networkd, iwd, dhcpcd.";
    homepage = "https://github.com/SubZ69/nmlinkd";
    changelog = "https://github.com/SubZ69/nmlinkd/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.starryreverie ];
  };
})
