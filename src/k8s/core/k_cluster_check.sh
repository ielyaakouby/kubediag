#!/usr/bin/env bash

RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m'

check_cluster_connectivity_snipp() {
    local message="$1"
    local command="$2"

    local delay=0.1
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    echo -n "⠿ $message... "

    bash -c "$command" &>/dev/null &
    local pid=$!

    while kill -0 $pid 2>/dev/null; do
        i=$(( (i + 1) % ${#spin} ))
        printf "\r%s %s..." "${spin:$i:1}" "$message"
        sleep $delay
    done

    wait $pid
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        printf "\r${GREEN}[✓] %s... done${NC}\n" "$message"
        print_separator
    else
        printf "\r${RED}[✖] %s... failed${NC}\n" "$message"
        return 1
    fi
}

cluster::check_connectivity() {
    if ! timeout 10s kubectl cluster-info &>/dev/null; then
        echo -e "${RED}[✖] Checking cluster connectivity... failed${NC}"
        return 1
    fi
}

