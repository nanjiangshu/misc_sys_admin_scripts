#!/usr/bin/env bash
set -euo pipefail

# This script installs the latest version of Go in a non-root environment

BIN_DIR="$HOME/bin"
INSTALL_BASE="$HOME"
TMP_DIR="$(mktemp -d)"

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "$ARCH" in
  x86_64) ARCH="amd64" ;;
  arm64|aarch64) ARCH="arm64" ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

# Fetch latest Go version
GO_VERSION="$(curl -fsSL https://go.dev/VERSION?m=text | head -n 1)"
TARBALL="${GO_VERSION}.${OS}-${ARCH}.tar.gz"
URL="https://go.dev/dl/${TARBALL}"

echo "▶ Installing ${GO_VERSION} for ${OS}/${ARCH}"

mkdir -p "$BIN_DIR"

echo "▶ Downloading ${URL}"
curl -fsSL "$URL" -o "$TMP_DIR/$TARBALL"

echo "▶ Extracting Go"
rm -rf "$INSTALL_BASE/go"
tar -C "$INSTALL_BASE" -xzf "$TMP_DIR/$TARBALL"

echo "▶ Linking go binary to $BIN_DIR"
ln -sf "$INSTALL_BASE/go/bin/go" "$BIN_DIR/go"

rm -rf "$TMP_DIR"

echo
echo "✅ Go installed successfully"
echo "👉 Version: $(go version 2>/dev/null || echo 'reload your shell')"
echo
echo "👉 Ensure ~/bin is in PATH:"
echo '   export PATH="$HOME/bin:$PATH"'
