{
  lib,
  nix-update,
  writeShellApplication,
  stdenvNoCC,
}:

{
  attrPath, # [String] | Path to the target derivation in the package set.
  branch ? null, # Nullable String | The optional unstable branch to track.
  extraArgs ? [ ], # [String] | Extra CLI arguments to pass to `nix-update`.
}:
let
  system = stdenvNoCC.hostPlatform.system;
  attrPathString = lib.strings.concatStringsSep "." attrPath;
in
writeShellApplication {
  name = "auto-update-${attrPathString}";

  runtimeInputs = [
    nix-update
  ];

  text = ''
    project_root="$PWD"
    while [[ ! -f "$project_root/flake.nix" && "$project_root" != "/" ]]; do
      project_root="$(dirname "$project_root")"
    done

    nix-update ${attrPathString} \
      -f "$project_root/pkgs/default.nix" \
      ${lib.strings.optionalString (branch != null) "--version=branch=${branch}"} \
      ${lib.strings.escapeShellArgs extraArgs}
  '';

  passthru.updateUtilsMeta = {
    inherit attrPath;
  };
}
