{
  lib,
  nix-update,
  writeShellApplication,
  stdenvNoCC,
}:
{
  attrPath, # [String] | Path to the target derivation in the package set.
  scriptFile, # Path | Path to the custom update script.
  extraArgs ? [ ], # [String] | Extra CLI arguments to pass to the script.
  extraRuntimeInputs ? [ ], # [Derivation] | Additional packages in `$PATH`.
}:
let
  system = stdenvNoCC.hostPlatform.system;
  attrPathString = lib.strings.concatStringsSep "." attrPath;
in
writeShellApplication {
  name = "custom-update-${attrPathString}";

  runtimeInputs = extraRuntimeInputs ++ [
    nix-update
  ];

  text = ''
    exec bash ${scriptFile} ${lib.strings.escapeShellArgs extraArgs}
  '';

  passthru.updateUtilsMeta = {
    inherit attrPath;
  };
}
