#!/bin/bash

set -e

INSTALL_DIR="$HOME/.kubediag"
BIN_DIR="$HOME/.local/bin"
LINK_PATH="$BIN_DIR/kubediag"

if [[ -d "$INSTALL_DIR/kubediag" || -L "$LINK_PATH" ]]; then
    echo "ℹ️  [INFO]  kubediag is installed. Proceeding with uninstallation..."

    if [[ -d "$INSTALL_DIR/kubediag" ]]; then
        echo "🗑️  [INFO]  Removing installation directory..."
        rm -rf "$INSTALL_DIR/kubediag"
    fi

    if [[ -L "$LINK_PATH" ]]; then
        echo "🗑️  [INFO]  Removing symbolic link..."
        rm "$LINK_PATH"
    fi

    echo "✅ [OK]    kubediag uninstalled successfully."
else
    echo "ℹ️  [INFO]  kubediag is not installed. Nothing to uninstall."
fi
