{
  buildGoModule,
  fetchurl,
  lib,
}:
buildGoModule (finalAttrs: {
  pname = "stinkpot";
  version = "0.1.0-unstable-2026-09-16";

  src = fetchurl {
    url = "https://tangled.org/oppi.li/stinkpot/archive/71ecf8b2ebcb0a0509040fba7622205ea243627a.tar.gz";
    hash = "sha256-D7swmsd9cRY9bkYUdbbhDQFOElqd84PQfgIeW0WAzSM=";
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
    maintainers = with lib.maintainers; [ starryreverie ];
  };
})
