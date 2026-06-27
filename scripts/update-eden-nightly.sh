#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
PKG="pkgs/eden-emu-nightly/package.nix"
API="https://git.eden-emu.dev/api/v1/repos/eden-ci/nightly/releases?limit=1"

tag=$(curl -fsSL "$API" | jq -r '.[0].tag_name')
tag="${tag#v}"
timestamp="${tag%%.*}"
commit="${tag#*.}"

url="https://nightly.eden-emu.dev/v${timestamp}.${commit}/Eden-Linux-${commit}-amd64-clang-pgo.AppImage"
echo "Último nightly: commit=${commit} timestamp=${timestamp}"
echo "URL: ${url}"

hash=$(nix store prefetch-file --json "$url" | jq -r '.hash')
echo "hash: ${hash}"

sed -i -E \
  -e "s|^(  timestamp = \")[0-9]+(\";)|\1${timestamp}\2|" \
  -e "s|^(  version = \")[0-9a-f]+(\";)|\1${commit}\2|" \
  -e "s|^(  hash = \")sha256-[A-Za-z0-9+/=]+(\";)|\1${hash}\2|" \
  "$PKG"

echo "Actualizado $PKG"
