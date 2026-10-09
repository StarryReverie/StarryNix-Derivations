# StarryNix-Derivations

## Overview

My NUR repository.

The design of this NUR is recorded in this [blog post](https://blog.starryreverie.cc/posts/automate-nur/) (zh_CN).

## Usage

### Adding Dependency

This repository can be added to your flake as an input.
Add the following code snippet to your `flake.nix`:

```nix
{
  inputs = {
    starrynix-derivations = {
      url = "github:StarryReverie/StarryNix-Derivations/main";
      inputs.flake-parts.follows = "flake-parts"; # Optional
      inputs.systems.follows = "systems"; # Optional
      # inputs.nixpkgs.follows = "nixpkgs"; # Possible but not recommended
    };
  };
}
```

Consuming this repository without flake enabled is also possible.
It's recommended to use a pinning tool such as `npins` or `niv` to ensure reproducibility.
Please refer to your pinning tool's manual to learn how to add external dependencies.

### Adding Binary Cache Server

This repository also provides a binary cache server to avoid rebuilding packages unnecessarily.
To acquire prebuilt artifacts, you need to use <https://starrynix-derivations.cachix.org/>
along with its public key `starrynix-derivations.cachix.org-1:xeKb1mqP+suib++KMMe64pofNgsSgDJQLgcV2FVNZ2s=`.

Add the following code snippet to your NixOS configurations:

```nix
{
  nix.settings.substituters = [
    "https://cache.nixos.org/"
    "https://nix-community.cachix.org/"
    "https://starrynix-derivations.cachix.org/"
  ];

  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "starrynix-derivations.cachix.org-1:xeKb1mqP+suib++KMMe64pofNgsSgDJQLgcV2FVNZ2s="
  ];
}
```

Because this NUR's cache server depends on <https://cache.nixos.org> and <https://nix-community.cachix.org>,
some existing store paths may not be uploaded again to avoid duplicaton.
If those two servers are not added, unexpected rebuilding may occur.

Note that this NUR's CI doesn't build the whole package set against every commit of `NixOS/nixpkgs/nixos-unstable`.
Instead, it updates the tracked branch every week and only those commits locked in `flake.lock` are considered.
That is to say, using the exact derivations from this NUR is the prerequisite of cache hit
and you're expected to use flake or the `flake-compat` interface to maximize reproducibility.

### Using Packages

If you're using flake, you can use `inputs.starrynix-derivations.legacyPackages.<system>.<package>` to refer to a particular package,
where `<system>` is your current system and can usually be acquired using `pkgs.stdenv.hostPlatform.system`.

If you're not using flake but you'd like to use the `flake-compat` interface,
you can use `(import sources.starrynix-derivations).legacyPackages.<system>.<package>` to refer to a particular package,
where `sources` is provided by your pinning tool.

If you're not using flake and you want to instantiate a fresh package set against an existing `pkgs` instance,
you can use `nur = import "${sources.starrynix-derivations}/pkgs/default.nix" { inherit pkgs; }` to get the package set.
Then use `nur.<package>` to refer to a particular package.

## License

This repository is licensed under the [MIT License](./LICENSE).

Copyright (C) 2025 Justin Chen
