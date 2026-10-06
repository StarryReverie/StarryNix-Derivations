{ lib }:
let
  # If cond is true, then return the value, return null otherwise.
  optionalNullable = # ... -> Nullable x
    cond: # Bool
    x: # x
    if cond then x else null;

  # Map elements to other elements or nulls and filter out nulls.
  mapNullables = # ... -> [x] -> [x]
    f: # x -> Nullable x
    lib.lists.concatMap (
      x:
      let
        y = f x;
      in
      if y != null then [ y ] else [ ]
    );
in
{
  inherit
    optionalNullable
    mapNullables
    ;
}
