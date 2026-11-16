{
  binaryen,
  buildWasmBindgenCli,
  fetchCrate,
  fetchFromForgejo,
  fetchPnpmDeps,
  lib,
  lld,
  llvmPackages,
  nodejs_26,
  pnpmConfigHook,
  pnpm_12,
  rustPlatform,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "sable-frontend";
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
    inherit (finalAttrs.passthru) pnpm;
    fetcherVersion = 4;
    hash = "sha256-LtOqaSAVBItWnQmnOZUXSakaIKkZnZnvqN86bhq3FjQ=";
  };

  nativeBuildInputs = [
    (pnpmConfigHook.override { inherit (finalAttrs.passthru) pnpm; })
    binaryen
    finalAttrs.passthru.nodejs
    finalAttrs.passthru.pnpm
    finalAttrs.passthru.wasm-bindgen-cli

    lld
    rustPlatform.cargoSetupHook
    rustPlatform.rust.cargo
    rustPlatform.rust.rustc
  ];

  env = {
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
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cp -r dist $out
    runHook postInstall
  '';

  passthru = {
    nodejs = nodejs_26;
    pnpm = pnpm_12;

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

    env = {
      inherit (finalAttrs.env)
        SABLE_BUILD_FLAVOR
        SABLE_FOSS
        VERSION
        VITE_APP_VERSION
        VITE_BUILD_HASH
        ;
    };
  };

  meta = {
    description = "Almost stable Matrix client (Frontend)";
    homepage = "https://git.sable.moe/SableClient/sable-next";
    changelog = "https://git.sable.moe/SableClient/sable-next/src/tag/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.all;
    broken = stdenv.hostPlatform.isDarwin;
    maintainers = [ lib.maintainers.starryreverie ];
  };
})
