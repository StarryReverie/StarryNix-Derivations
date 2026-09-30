{
  lib,
  nixfmt,
  writeShellApplication,
}:

innerUpdater: # Derivation | Derivation of the underlying updater script.
let
  inherit (innerUpdater.updateUtilsMeta) attrPath;

  attrFilesystemPathString = "pkgs/${lib.strings.concatStringsSep "/" attrPath}";
in
writeShellApplication {
  name = "${innerUpdater.name}-with-formatter";

  runtimeInputs = [
    nixfmt
  ];

  text = ''
    project_root="$PWD"
    while [[ ! -f "$project_root/flake.nix" && "$project_root" != "/" ]]; do
      project_root="$(dirname "$project_root")"
    done

    ${lib.getExe innerUpdater}

    for file in "$project_root"/${attrFilesystemPathString}/*.nix ; do
      echo "$file"
      nixfmt "$file"
    done
  '';

  passthru = innerUpdater.passthru or { };
}
