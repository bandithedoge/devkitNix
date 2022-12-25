#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-prefetch-docker
# shellcheck shell=bash

function fetch() {
  nix-prefetch-docker --image-name "devkitpro/$1" --json --quiet > "sources/$1.json"
}

mkdir -p sources

fetch devkitarm
fetch devkita64
fetch devkitppc
