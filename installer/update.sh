#!/bin/bash
set -euo pipefail

INSTALL_DIR="$HOME/.kubediag"

log_info()  { echo -e "ℹ️  \033[1;34m[INFO]\033[0m  $*"; }
log_ok()    { echo -e "✅ \033[1;32m[OK]\033[0m    $*"; }
log_error() { echo -e "❌ \033[1;31m[ERROR]\033[0m $*"; }

if [[ ! -d "$INSTALL_DIR/.git" ]]; then
  log_error "kubediag is not installed or not a git repo."
  log_info "Run install.sh first."
  exit 1
fi

log_info "Updating kubediag..."
cd "$INSTALL_DIR"
git pull --quiet
log_ok "kubediag has been updated to the latest version."
