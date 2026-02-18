#!/usr/bin/env bash

# ============================================================================
# Migration Script: Replace old menus with refactored versions
# This script backs up old menu files and replaces them with refactored versions
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MENU_DIR="$SCRIPT_DIR/src/k8s/menu"
BACKUP_DIR="$MENU_DIR/backup_$(date +%Y%m%d_%H%M%S)"

echo "🔄 Starting menu migration..."
echo "📁 Menu directory: $MENU_DIR"
echo "💾 Backup directory: $BACKUP_DIR"
echo ""

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup old files
echo "📦 Backing up old menu files..."
cp "$MENU_DIR/main_menu_ok.sh" "$BACKUP_DIR/main_menu_ok.sh.backup" 2>/dev/null || true
cp "$MENU_DIR/monitoring_menu.sh" "$BACKUP_DIR/monitoring_menu.sh.backup" 2>/dev/null || true
cp "$MENU_DIR/_troubleshooting_menu.sh" "$BACKUP_DIR/_troubleshooting_menu.sh.backup" 2>/dev/null || true

# Replace with refactored versions
echo "✨ Replacing with refactored versions..."

if [[ -f "$MENU_DIR/main_menu_refactored.sh" ]]; then
    cp "$MENU_DIR/main_menu_refactored.sh" "$MENU_DIR/main_menu_ok.sh"
    echo "  ✓ Replaced main_menu_ok.sh"
else
    echo "  ✗ main_menu_refactored.sh not found!"
    exit 1
fi

if [[ -f "$MENU_DIR/monitoring_menu_refactored.sh" ]]; then
    cp "$MENU_DIR/monitoring_menu_refactored.sh" "$MENU_DIR/monitoring_menu.sh"
    echo "  ✓ Replaced monitoring_menu.sh"
else
    echo "  ✗ monitoring_menu_refactored.sh not found!"
    exit 1
fi

if [[ -f "$MENU_DIR/troubleshooting_menu_refactored.sh" ]]; then
    cp "$MENU_DIR/troubleshooting_menu_refactored.sh" "$MENU_DIR/_troubleshooting_menu.sh"
    echo "  ✓ Replaced _troubleshooting_menu.sh"
else
    echo "  ✗ troubleshooting_menu_refactored.sh not found!"
    exit 1
fi

echo ""
echo "✅ Migration completed!"
echo "📦 Backups saved in: $BACKUP_DIR"
echo ""
echo "🧪 To test, run: ./kubediag.sh"
echo ""

