#!/usr/bin/bash

ok_k_switch() {
    local TEMP_DIR=${TEMP_DIR:-"/data/winw/carrefour/caas/repos/onecaas/tmp"}
    local kubeconfig_dir="$TEMP_DIR/kubeconfig"
    local COLOR_YELLOW="\e[1;33m"
    local COLOR_RED="\e[1;31m"
    local COLOR_RESET="\e[0m"

    [[ ! -d "$kubeconfig_dir" ]] && echo -e "${COLOR_RED}Error:${COLOR_RESET} Directory $kubeconfig_dir does not exist." && return 1

    local selected_file
    selected_file=$(ls -d "$kubeconfig_dir"/* 2>/dev/null | grep -vE "\-rancher|\-gcloud|az-local" | fzf --exact)

    [[ -n "$selected_file" ]] && export KUBECONFIG="$selected_file" && echo -e "${COLOR_YELLOW}KUBECONFIG set to:${COLOR_RESET} $KUBECONFIG" || echo -e "${COLOR_RED}No file selected. KUBECONFIG not changed.${COLOR_RESET}"
}