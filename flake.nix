{
  description = "matsu";

  nixConfig = {
    "extra-substituters" = [
      "https://cache.nixos.org"
    ];
    "extra-trusted-public-keys" = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    isl-src = {
      url = "git+https://repo.or.cz/isl.git?ref=refs/heads/master";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, isl-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        islLatest = pkgs.isl.overrideAttrs (old: {
          version = "unstable";
          src = isl-src;
          nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.autoreconfHook ];
        });
      in
      {
        packages = {
          isl-latest = islLatest;
          default = islLatest;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            islLatest
          ];

          packages = [
            pkgs.idris2
            pkgs.pkg-config
          ];
        };
      });
}
