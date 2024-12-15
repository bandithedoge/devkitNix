#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-prefetch-docker fd
# shellcheck shell=bash

function fetch() {
    echo "fetching $1..."
    nix-prefetch-docker --image-name "devkitpro/$1" --json --quiet >"sources/$1.json"
}

fd flake.nix -x nix flake update --flake "{//}" --option access-tokens "github.com=$GITHUB_TOKEN"

mkdir -p sources

fetch devkitarm
fetch devkita64
fetch devkitppc
