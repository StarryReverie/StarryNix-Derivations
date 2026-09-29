{ lib }:
let
  inherit (import ./nullables.nix { inherit lib; })
    mapNullables
    ;
in
let
  # Transform the attrset and optionally filter out some elements.
  filterMapAttrsRecursiveCond = # ... -> Attrset
    recursePred: # AttrSet -> Bool | Whether to recurse into this attrset or treat it as leaf.
    mapper: # [String] -> Any -> Nullable Any | Map this leaf element given its path.
    attrs: # AttrSet | The attrset to transform.
    let
      recurseImpl = # ... -> Attrset
        path: # [String]
        attrs: # Attrset
        lib.pipe attrs [
          lib.attrsets.attrsToList
          (mapNullables (
            { name, value }:
            let
              subPath = path ++ [ name ];
              shouldRecurse = lib.isAttrs value && recursePred value;
              newValue = if shouldRecurse then recurseImpl subPath value else mapper subPath value;
            in
            lib.mapNullable (lib.attrsets.nameValuePair name) newValue
          ))
          lib.attrsets.listToAttrs
        ];
    in
    recurseImpl [ ] attrs;
in
{
  inherit
    filterMapAttrsRecursiveCond
    ;
}
