{
  aws-lc,
  fetchFromGitHub,
  lib,
  makeWrapper,
  pkg-config,
  rustPlatform,
  udev,
  updateUtils,
  writeTextFile,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ostool";
  version = "0.32.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "drivercraft";
    repo = "ostool";
    tag = "ostool-v${finalAttrs.version}";
    hash = "sha256-9b9MEcfjLo7S6Owll4u/TXdJEmf644wKIKtxAmW4vA8=";
  };

  cargoHash = "sha256-H0Eh+iw61A/fUQNuhqRN3gW1VyD6Gi/VccItaaThlHI=";

  buildAndTestSubdir = [ "ostool" ];

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    aws-lc
    udev.dev
  ];

  postInstall = ''
    wrapProgram $out/bin/ostool \
      --run '
        mkdir -p ~/.ostool
        rm -f ~/.ostool/config.toml || true
        ln -s ${finalAttrs.passthru.configFile}/config.toml ~/.ostool/config.toml
      '
  '';

  doCheck = false;

  passthru = {
    configFile = writeTextFile {
      name = "ostool-config";
      destination = "/config.toml";

      text = ''
        [board]
        server = "https://ostool.muxai.net:14321"
        auth_mode = "required"
      '';
    };

    updateScript =
      let
        baseUpdater = updateUtils.updateAuto {
          attrPath = [ "ostool" ];
        };
      in
      lib.pipe baseUpdater [
        updateUtils.withFormatter
        updateUtils.withGitCommit
      ];
  };

  meta = {
    description = "Toolset for building OS using Rust";
    homepage = "https://github.com/drivercraft/ostool";
    mainProgram = "ostool";
    license = lib.licenses.OR [
      lib.licenses.mit
      lib.licenses.asl20
    ];
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.starryreverie ];
  };
})
