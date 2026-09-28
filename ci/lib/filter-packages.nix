{
  lib,
  scope,
}:
let
  isNotEmpty = value: value != null && value != { };
in
drvPred:
lib.pipe scope [
  (lib.attrsets.mapAttrsRecursiveCond (attrs: !(lib.isDerivation attrs)) (
    path: value: if lib.isDerivation value then value else null
  ))
  (lib.attrsets.filterAttrsRecursive (name: value: isNotEmpty value && drvPred value))
]
