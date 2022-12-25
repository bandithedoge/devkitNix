{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devkitNix.url = "path:../../.";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    devkitNix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [devkitNix.overlays.default];
      };
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = [pkgs.devkitNix.devkitA64];
        inherit (pkgs.devkitNix.devkitA64) shellHook;
      };
      packages.default = pkgs.stdenv.mkDerivation {
        name = "devkitA64-example";
        src = ./.;

        makeFlags = ["TARGET=example"];
        preBuild = pkgs.devkitNix.devkitA64.shellHook;
        installPhase = ''
          cp example.nro $out
        '';
      };
    });
}
