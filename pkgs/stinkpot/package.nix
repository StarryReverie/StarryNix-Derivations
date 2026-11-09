{
  buildGoModule,
  fetchFromTangled,
  lib,
}:
buildGoModule (finalAttrs: {
  pname = "stinkpot";
  version = "0.1.0-unstable-2026-09-16";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromTangled {
    did = "did:plc:wqstj3k5tslmm246baaf3tpa";
    rev = "71ecf8b2ebcb0a0509040fba7622205ea243627a";
    hash = "sha256-Ku4xDZwvtGcMADQ0xrzznyHLQjEttDJTF2jzP8Yhgv8=";
  };

  vendorHash = "sha256-IVPACl1oWnBKGzcXvG5gzev8MwhzIKNI7zwEKJjhFc8=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "SQLite-backed shell history";
    homepage = "https://tangled.org/oppi.li/stinkpot";
    mainProgram = "stinkpot";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.starryreverie ];
  };
})
