{ lib }:
let
  inherit (import ../../lib/nullables.nix { inherit lib; })
    optionalNullable
    ;
  inherit (import ../../lib/filter-map-attrs-recursive-cond.nix { inherit lib; })
    filterMapAttrsRecursiveCond
    ;
in
let
  # Selectively retrieve packages with some metadata and filter out non-derivation elements using a
  # custom predicate. Each derivation element will be replaced with its corresponding metadata.
  evalJobSet = # ... -> AttrSet
    drvPred: # Derivation -> Bool | Whether to build this derivation.
    toJobMetadata: # [String] -> Derivation -> Any | Extract metadata from a derivation.
    packageSet: # AttrSet | Package set to process.
    filterMapAttrsRecursiveCond (attrs: !(lib.isDerivation attrs)) (
      path: value:
      let
        isNotEmpty = value != null && value != { };
        isValidDrv = lib.isDerivation value && drvPred value;

        addJobMetadataTag =
          value: if builtins.isAttrs value then value // { customType = "jobMetadata"; } else value;
      in
      optionalNullable (isNotEmpty && isValidDrv) (addJobMetadataTag (toJobMetadata path value))
    ) packageSet;

  # Selectively retrieve packages with some metadata and filter out non-derivation elements using a
  # custom predicate. All extracted metadata will be collected in a list.
  evalJobList = # ... -> [AttrSet]
    drvPred: # Derivation -> Bool | Whether to build this derivation.
    toJobMetadata: # [String] -> Derivation -> Any | Extract metadata from a derivation.
    packageSet: # AttrSet | Package set to process.
    let
      flattenImpl =
        value:
        if lib.isAttrs value then
          if value.customType or "" == "jobMetadata" then
            [ value ]
          else
            lib.lists.concatMap flattenImpl (lib.attrsets.attrValues value)
        else
          [ value ];
    in
    flattenImpl (evalJobSet drvPred toJobMetadata packageSet);
in
{
  inherit
    evalJobSet
    evalJobList
    ;
}
