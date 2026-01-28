callPackage: {
	cavasik = callPackage ./cavasik/package.nix { };

	kvlibadwaita = callPackage ./kvlibadwaita/package.nix { };

	orchis-kde = callPackage ./orchis-kde/package.nix { };
}
