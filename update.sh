#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-prefetch-docker fd
# shellcheck shell=bash

function fetch() {
    echo "fetching $1-$2..."
    nix-prefetch-docker --image-name "devkitpro/$1" --arch $2 --json --quiet >"sources/$1-$2.json"
}

fd flake.nix -x nix flake update --flake "{//}" --option access-tokens "github.com=$GITHUB_TOKEN"

mkdir -p sources

fetch devkitarm amd64
fetch devkitarm arm64
fetch devkita64 amd64
fetch devkita64 arm64
fetch devkitppc amd64
fetch devkitppc arm64
