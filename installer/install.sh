#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_DIR="$HOME/.local/bin"

mkdir -p "$BIN_DIR"

ln -sf "$SCRIPT_DIR/bin/kubediag.sh" "$BIN_DIR/kubediag"
chmod +x "$SCRIPT_DIR/bin/kubediag.sh"

# Ajout au PATH si nécessaire
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$HOME/.bashrc"
  echo "[+] Added $BIN_DIR to PATH in .bashrc"
  echo "[i] Please run 'source ~/.bashrc' or open a new terminal to apply changes."
fi

echo "[✓] kubediag installed successfully. Run 'kubediag' to get started."

# Verify checksum
