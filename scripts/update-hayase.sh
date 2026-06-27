#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
PKG="pkgs/hayase/package.nix"
MANIFEST="https://api.hayase.watch/files/latest-linux.yml"

version=$(curl -fsSL "$MANIFEST" | grep -m1 '^version:' | awk '{print $2}' | tr -d '\r')
url="https://api.hayase.watch/files/linux-hayase-${version}-linux.AppImage"
echo "Última hayase: ${version}"
echo "URL: ${url}"

hash=$(nix store prefetch-file --json "$url" | jq -r '.hash')
echo "hash: ${hash}"

sed -i -E \
  -e "s|(version = \")[0-9.]+(\";)|\1${version}\2|" \
  -e "s|(hash = \")sha256-[A-Za-z0-9+/=]+(\";)|\1${hash}\2|" \
  "$PKG"

echo "Actualizado $PKG"
