#!/usr/bin/env bash

###########################################
# Kubernetes Management Script
# Version: 2.0
# Author: Ismail Elyaakouby
# Description: Comprehensive Kubernetes cluster management tool
###########################################

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

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/../" && pwd)"

TMPDIR="${TMPDIR:-/tmp}"
OK_FILE="${TMPDIR}/kubediag-ok-$$"
NOK_FILE="${TMPDIR}/kubediag-nok-$$"
TMP_ALL_PODS="${TMPDIR}/kubediag-pods-$$"
TMP_NODE_REPORT="${TMPDIR}/kubediag-nodes-$$"
TMP_NODE_COUNTS="${TMPDIR}/kubediag-counts-$$"

# Track loaded functions for cleanup
tracked_functions=""

# Track temporary files created with mktemp for cleanup
TEMP_FILES_FILE="${TMPDIR}/kubediag-temp-files-$$"
touch "$TEMP_FILES_FILE"

set -e

###########################################
# kubediag::load_modules
###########################################
kubediag::load_modules() {
    local paths=(
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
    
    local menu_dir="$SCRIPT_DIR/src/k8s/menu"
    if [[ -d "$menu_dir" ]]; then
        if [[ -f "$menu_dir/menu_ui_enhanced.sh" ]]; then
            if ! source "$menu_dir/menu_ui_enhanced.sh"; then
                echo "Error: Failed to load menu_ui_enhanced.sh" >&2
                return 1
            fi
        fi
        
        if [[ -f "$menu_dir/main_menu_enhanced.sh" ]]; then
            if ! source "$menu_dir/main_menu_enhanced.sh"; then
                echo "Error: Failed to load main_menu_enhanced.sh" >&2
                return 1
            fi
        fi
        
        if [[ -f "$menu_dir/main_menu_ok.sh" ]]; then
            if ! source "$menu_dir/main_menu_ok.sh"; then
                echo "Error: Failed to load main_menu_ok.sh" >&2
                return 1
            fi
        fi
        
        for script in "$menu_dir"/*.sh; do
            if [[ -f "$script" ]]; then
                local basename
                basename=$(basename "$script")
                if [[ "$basename" != "menu_ui_enhanced.sh" && \
                      "$basename" != "main_menu_enhanced.sh" && \
                      "$basename" != "main_menu_ok.sh" && \
                      "$basename" != "main_menu_refactored.sh" ]]; then
                    if ! source "$script"; then
                        echo "Error: Failed to load $script" >&2
                        return 1
                    fi
                fi
            fi
        done
    fi

    local before_funcs
    before_funcs=$(declare -F | awk '{print $3}' | sort)

    for dir in "${paths[@]}"; do
        if [[ ! -d "$dir" ]]; then
            echo "Warning: Directory $dir does not exist" >&2
            continue
        fi
        
        for script in "$dir"/*.sh; do
            if [[ -f "$script" ]]; then
                if ! source "$script"; then
                    echo "Error: Failed to load $script" >&2
                    return 1
                fi
            fi
        done
    done

    local after_funcs
    after_funcs=$(declare -F | awk '{print $3}' | sort)

    tracked_functions=$(comm -13 <(echo "$before_funcs") <(echo "$after_funcs"))
}

###########################################
# register_temp_file
###########################################
register_temp_file() {
    local file="$1"
    if [[ -n "$file" && -f "$TEMP_FILES_FILE" ]]; then
        echo "$file" >> "$TEMP_FILES_FILE"
    fi
}

###########################################
# cleanup
###########################################
cleanup() {
    local temp_files=(
        "$OK_FILE"
        "$NOK_FILE"
        "$TMP_ALL_PODS"
        "$TMP_NODE_REPORT"
        "$TMP_NODE_COUNTS"
    )
    
    for file in "${temp_files[@]}"; do
        if [[ -f "$file" ]]; then
            rm -f "$file"
        fi
    done
    
    if [[ -f "$TEMP_FILES_FILE" ]]; then
        while IFS= read -r file; do
            if [[ -n "$file" && -f "$file" ]]; then
                rm -f "$file" 2>/dev/null || true
            fi
        done < "$TEMP_FILES_FILE"
        rm -f "$TEMP_FILES_FILE"
    fi
    
    local patterns=(
        "*_describe_*.txt"
        "*_pod_*.yaml"
        "*_svc_*.yaml"
        "*_configmap_*.yaml"
        "*_deployment_*.yaml"
        "*_statefulset_*.yaml"
        "*_daemonset_*.yaml"
        "*_ingress_*.yaml"
        "*_pod-logs-*.log"
        "*_resource-yaml.yaml"
        "*_rollout-history.txt"
    )
    
    for pattern in "${patterns[@]}"; do
        find "${TMPDIR:-/tmp}" -maxdepth 1 -type f -name "$pattern" \
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
        echo "Error: Cannot connect to Kubernetes cluster" >&2
        return 1
    fi
    
    menu::select_main_action
}

###########################################
# Entry point
###########################################
if [[ "${1:-}" == "ok" ]]; then
    kubediag::load_modules
else
    kubediag::run_main
fi
