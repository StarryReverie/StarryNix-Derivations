{
  git,
  lib,
  nix,
  stdenvNoCC,
  writeShellApplication,
}:

innerUpdater: # Derivation | Derivation of the underlying updater script.
let
  inherit (innerUpdater.updateUtilsMeta) attrPath;

  system = stdenvNoCC.hostPlatform.system;
  attrPathString = lib.strings.concatStringsSep "." attrPath;
  attrFilesystemPathString = "pkgs/${lib.strings.concatStringsSep "/" attrPath}";
in
writeShellApplication {
  name = "${innerUpdater.name}-with-git-commit";

  runtimeInputs = [
    git
    nix
  ];

  text = ''
    function get_version() {
      nix --extra-experimental-features 'nix-command flakes' \
        eval .#legacyPackages.${system}.${attrPathString}.version \
        --raw
    }

    project_root="$PWD"
    while [[ ! -f "$project_root/flake.nix" && "$project_root" != "/" ]]; do
      project_root="$(dirname "$project_root")"
    done

    old_version="$(get_version)"

    ${lib.getExe innerUpdater}

    new_version="$(get_version)"

    if [[ "$old_version" != "$new_version" ]]; then
      git -C "$project_root" \
        commit -m "${attrFilesystemPathString}: $old_version -> $new_version" \
        --only \
        -- "$project_root/${attrFilesystemPathString}"
    fi
  '';

  passthru = innerUpdater.passthru or { };
}
