{
  system ? builtins.currentSystem,
  pkgs ? (import ../.).inputs.nixpkgs.legacyPackages.${system},
}:
let
  lib = pkgs.lib;

  singletonAttrs = name: value: { ${name} = value; };

  packageSetRecursiveImpl =
    includePred: newScope: dir:
    let
      dirEntries = builtins.readDir dir;

      leafPaths = lib.flip lib.attrsets.concatMapAttrs dirEntries (
        entry: type:
        if type == "directory" && builtins.pathExists (dir + /${entry}/package.nix) then
          singletonAttrs entry (dir + /${entry}/package.nix)
        else if type == "regular" && lib.strings.hasSuffix ".nix" entry && includePred entry then
          singletonAttrs (lib.strings.removeSuffix ".nix" entry) (dir + /${entry})
        else
          { }
      );

      branchPaths = lib.flip lib.attrsets.concatMapAttrs dirEntries (
        entry: type:
        if type == "directory" && !(builtins.pathExists (dir + /${entry}/package.nix)) then
          singletonAttrs entry (dir + /${entry}/.)
        else
          { }
      );

      scope = lib.makeScope newScope (
        self:
        let
          packages = lib.attrsets.mapAttrs (name: path: self.callPackage path { }) leafPaths;
          packageSets = lib.attrsets.mapAttrs (
            name: packageSetRecursiveImpl includePred self.newScope
          ) branchPaths;
        in
        packages // packageSets
      );
    in
    scope;

  packageSetRecursiveWithPred = includePred: packageSetRecursiveImpl includePred pkgs.newScope;

  packageSetRecursive = packageSetRecursiveWithPred (entry: entry != "default.nix");
in
packageSetRecursive ./.
