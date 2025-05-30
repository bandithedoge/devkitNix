{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devkitNix.url = "github:bandithedoge/devkitNix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      devkitNix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ devkitNix.overlays.default ];
        };
      in
      {
        devShells.default = pkgs.mkShell.override { stdenv = pkgs.devkitNix.stdenvA64; } { };
        packages.default = pkgs.devkitNix.stdenvA64.mkDerivation {
          name = "devkitA64-example";
          src = ./.;

          makeFlags = [ "TARGET=example" ];
          installPhase = ''
            mkdir $out
            cp example.nro $out
          '';
        };
      }
    );
}
