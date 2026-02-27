#!/usr/bin/env bash


# shellcheck disable=SC1090,SC2034
# SPDX-License-Identifier: MIT
#
# kubediag — Interactive Kubernetes Diagnostics & Management
# Copyright (c) 2026 Ismail Elyaakouby
# https://github.com/ielyaakouby/kubediag
#
# Usage:
#   kubediag              Launch interactive menu
#   kubediag ok           Load modules only (library mode)
#   kubediag --version    Print version
#   kubediag --help       Show usage
#

set -e

readonly KUBEDIAG_VERSION="3.0.0"

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../" && pwd)"
readonly SCRIPT_DIR

NAMESPACE=""
POD_NAME=""
SVC_NAME=""
INGRESSE_NAME=""
DEPLOYMENT_NAME=""
STATEFULSET_NAME=""
DAEMONSET_NAME=""
NODE_NAME=""
CONFIGMAP_NAME=""
RESOURCE_NAME=""

TMPDIR="${TMPDIR:-/tmp}"
OK_FILE="${TMPDIR}/kubediag-ok-$$"
NOK_FILE="${TMPDIR}/kubediag-nok-$$"
TMP_ALL_PODS="${TMPDIR}/kubediag-pods-$$"
TMP_NODE_REPORT="${TMPDIR}/kubediag-nodes-$$"
TMP_NODE_COUNTS="${TMPDIR}/kubediag-counts-$$"
TEMP_FILES_FILE="${TMPDIR}/kubediag-temp-files-$$"
touch "$TEMP_FILES_FILE"

# ── Function tracking (for cleanup) ─────────────────────────────────────────
tracked_functions=""

# Register a file for automatic cleanup on exit.
register_temp_file() {
    local file="$1"
    if [[ -n "$file" && -f "$TEMP_FILES_FILE" ]]; then
        echo "$file" >> "$TEMP_FILES_FILE"
    fi
}

###########################################
# kubediag::load_modules
###########################################
kubediag::load_modules() {
    # Menu modules — order-sensitive priority loading
    local menu_dir="$SCRIPT_DIR/src/k8s/menu"
    if [[ -d "$menu_dir" ]]; then
        for pri in menu_ui_enhanced.sh main_menu_enhanced.sh main_menu_ok.sh; do
            [[ -f "$menu_dir/$pri" ]] || continue
            source "$menu_dir/$pri" || { echo "Error: Failed to load $pri" >&2; return 1; }
        done

        for script in "$menu_dir"/*.sh; do
            [[ -f "$script" ]] || continue
            local bname; bname=$(basename "$script")
            case "$bname" in
                menu_ui_enhanced.sh|main_menu_enhanced.sh|main_menu_ok.sh|main_menu_refactored.sh) continue ;;
            esac
            source "$script" || { echo "Error: Failed to load $script" >&2; return 1; }
        done
    fi

    # Core modules — snapshot functions for cleanup tracking
    local before_funcs
    before_funcs=$(declare -F | awk '{print $3}' | sort)

    local -a paths=(
        "$SCRIPT_DIR/src/k8s/common"
        "$SCRIPT_DIR/src/k8s/core"
        "$SCRIPT_DIR/src/k8s/helpers"
        "$SCRIPT_DIR/src/k8s/selectors"
        "$SCRIPT_DIR/src/k8s/tools"
        "$SCRIPT_DIR/src/k8s/monitoring"
        "$SCRIPT_DIR/src/k8s/troubleshoot"
        "$SCRIPT_DIR/src/k8s/actions/config"
        "$SCRIPT_DIR/src/k8s/actions/inspect"
        "$SCRIPT_DIR/src/k8s/actions/networking"
        "$SCRIPT_DIR/src/k8s/actions/pods"
        "$SCRIPT_DIR/src/k8s/actions/rollout"
        "$SCRIPT_DIR/src/k8s/others"
    )

    for dir in "${paths[@]}"; do
        if [[ ! -d "$dir" ]]; then
            echo "Warning: Directory $dir does not exist" >&2
            continue
        fi
        for script in "$dir"/*.sh; do
            [[ -f "$script" ]] || continue
            source "$script" || { echo "Error: Failed to load $script" >&2; return 1; }
        done
    done

    local after_funcs
    after_funcs=$(declare -F | awk '{print $3}' | sort)
    tracked_functions=$(comm -13 <(echo "$before_funcs") <(echo "$after_funcs"))
}

###########################################
# cleanup
###########################################

cleanup() {
    for file in "$OK_FILE" "$NOK_FILE" "$TMP_ALL_PODS" "$TMP_NODE_REPORT" "$TMP_NODE_COUNTS"; do
        [[ -f "$file" ]] && rm -f "$file"
    done

    if [[ -f "$TEMP_FILES_FILE" ]]; then
        while IFS= read -r file; do
            [[ -n "$file" && -f "$file" ]] && rm -f "$file" 2>/dev/null || true
        done < "$TEMP_FILES_FILE"
        rm -f "$TEMP_FILES_FILE"
    fi

    local -a patterns=(
        "*_describe_*.txt"   "*_pod_*.yaml"         "*_svc_*.yaml"
        "*_configmap_*.yaml" "*_deployment_*.yaml"  "*_statefulset_*.yaml"
        "*_daemonset_*.yaml" "*_ingress_*.yaml"     "*_pod-logs-*.log"
        "*_resource-yaml.yaml" "*_rollout-history.txt"
    )
    for pattern in "${patterns[@]}"; do
        find "${TMPDIR}" -maxdepth 1 -type f -name "$pattern" \
            -user "$(whoami)" -mmin -60 2>/dev/null | while read -r file; do
            rm -f "$file" 2>/dev/null || true
        done
    done
}

###########################################
# kubediag::cleanup_modules
###########################################
kubediag::cleanup_modules() {
    if [[ -n "$tracked_functions" ]]; then
        for func in $tracked_functions; do
            unset -f "$func" 2>/dev/null || true
        done
    fi
}

###########################################
# kubediag::run_main
###########################################
kubediag::run_main() {
    trap cleanup EXIT

    if ! kubediag::load_modules; then
        echo "Error: Failed to load required modules" >&2
        return 1
    fi

    if ! cluster::check_connectivity; then
        return 1
    fi

    menu::select_main_action
}

###########################################
# Entry point
###########################################
case "${1:-}" in
    ok)
        kubediag::load_modules
        ;;
    --version|-v)
        echo "kubediag v${KUBEDIAG_VERSION}"
        ;;
    --help|-h)
        sed -n '5,/^$/{ s/^# \?//; p }' "${BASH_SOURCE[0]}"
        ;;
    *)
        kubediag::run_main
        ;;
esac

