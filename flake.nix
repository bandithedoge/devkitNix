{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  }: let
    mkDevkit = pkgs: {
      name,
      src,
      includePaths ? [],
    }:
      pkgs.stdenv.mkDerivation (finalAttrs: {
        inherit name;
        src = pkgs.dockerTools.pullImage (pkgs.lib.importJSON src);

        nativeBuildInputs = with pkgs; [
          autoPatchelfHook
        ];

        buildInputs = with pkgs; [
          ncurses
          stdenv.cc.cc.lib
        ];

        dontPatchShebangs = true;

        phases = ["buildPhase" "fixupPhase"];

        buildPhase = ''
          tar -xf $src

          for archive in $(find *.tar)
          do
            tar -xf $archive
          done

          mkdir -p $out
          cp -r opt $out/opt
          ln -sf $out/opt/devkitpro/tools/bin $out/bin
          rm $out/opt/devkitpro/pacman/share/pacman/keyrings
        '';

        passthru = rec {
          CPATH = pkgs.lib.makeSearchPath "include" (builtins.map (x: "${finalAttrs.finalPackage}/opt/devkitpro/${x}") includePaths);

          shellHook = pkgs.lib.warn "shellHook is deprecated, please consider using devkitNix stdenv packages instead (see README)" ''
            export DEVKITPRO="${finalAttrs.finalPackage}/opt/devkitpro"
            export DEVKITARM="$DEVKITPRO/devkitARM"
            export DEVKITPPC="$DEVKITPRO/devkitPPC"
            export CPATH=${CPATH}
            export PATH="${pkgs.lib.makeBinPath ["$DEVKITPRO" "$DEVKITARM" "$DEVKITPPC"]}:$PATH"
          '';
        };
      });

    packages = pkgs: rec {
      devkitA64 = mkDevkit pkgs {
        name = "devkitA64";
        src = ./sources/devkita64.json;
        includePaths = [
          "devkitA64"
          "devkitA64/aarch64-none-elf"
          "libnx"
          "portlibs/switch"
        ];
      };
      devkitARM = mkDevkit pkgs {
        name = "devkitARM";
        src = ./sources/devkitarm.json;
        includePaths = [
          "devkitARM"
          "devkitARM/arm-none-eabi"
          "libctru"
          "libgba"
          "libmirko"
          "libnds"
          "liborcus"
          "libtonc"
          "portlibs/3ds"
          "portlibs/armv4t"
          "portlibs/gba"
          "portlibs/gp2x"
          "portlibs/nds"
        ];
      };
      devkitPPC = mkDevkit pkgs {
        name = "devkitPPC";
        src = ./sources/devkitppc.json;
        includePaths = [
          "devkitPPC"
          "devkitPPC/powerpc-eabi"
          "libogc"
          "portlibs/gamecube"
          "portlibs/ppc"
          "portlibs/wii"
          "portlibs/wiiu"
          "wut"
        ];
      };

      stdenvA64 = pkgs.stdenvAdapters.addAttrsToDerivation {
        nativeBuildInputs = [devkitA64];
        env.DEVKITPRO = devkitA64 + "/opt/devkitpro";
      } pkgs.stdenvNoCC;

      stdenvARM = pkgs.stdenvAdapters.addAttrsToDerivation {
        nativeBuildInputs = [devkitARM];
        env.DEVKITPRO = devkitARM + "/opt/devkitpro";
      } pkgs.stdenvNoCC;

      stdenvPPC = pkgs.stdenvAdapters.addAttrsToDerivation {
        nativeBuildInputs = [devkitPPC];
        env.DEVKITPRO = devkitPPC + "/opt/devkitpro";
      } pkgs.stdenvNoCC;
    };
  in
    (flake-utils.lib.eachDefaultSystem (system: let
      pkgs' = nixpkgs.legacyPackages.${system};
    in {
      packages = packages pkgs';
    }))
    // {
      overlays.default = final: prev: {
        devkitNix = packages prev;
      };
    };
}
