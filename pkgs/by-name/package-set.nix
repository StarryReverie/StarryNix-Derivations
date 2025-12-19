callPackage: {
	cavasik = callPackage ./cavasik/package.nix { };

	lx-music = callPackage ./lx-music/package.nix { };

	orchis-kde = callPackage ./orchis-kde/package.nix { };
}
