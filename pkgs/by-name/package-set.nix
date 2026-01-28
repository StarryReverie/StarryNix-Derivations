rawPkgs: callPackage: {
	cavasik = rawPkgs.cavasik;

	kvlibadwaita = callPackage ./kvlibadwaita/package.nix { };

	orchis-kde = callPackage ./orchis-kde/package.nix { };
}
