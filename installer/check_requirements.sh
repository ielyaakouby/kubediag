#!/usr/bin/env bash

RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m'

run_with_spinner_and_dots() {
    local label="$1"
    local command="$2"
    local total_width=60
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local delay=0.1
    local i=0

    bash -c "$command" &>/dev/null &
    local pid=$!

    while kill -0 $pid 2>/dev/null; do
        i=$(( (i + 1) % ${#spin} ))
        printf "\r%s %s..." "${spin:$i:1}" "$label"
        sleep $delay
    done

    wait $pid
    local exit_code=$?

    local spacing=$(( total_width - ${#label} - 7 ))
    local dots=""
    for ((j = 0; j < spacing; j++)); do
        dots+="."
    done

    if [ $exit_code -eq 0 ]; then
        printf "\r${GREEN}[✓] %s%s done${NC}\n" "$label" "$dots"
    else
        printf "\r${RED}❌ [FAIL]  %s%s failed${NC}\n" "$label" "$dots"
    fi

    return $exit_code
}

check_all_commands() {
    local missing=()
    local required=(git curl bash gnome-terminal fzf)

    run_with_spinner_and_dots "Checking required commands" "sleep 1"

    for cmd in "${required[@]}"; do
        if ! run_with_spinner_and_dots "$cmd" "command -v $cmd"; then
            missing+=("$cmd")
        fi
    done

    echo

    if [ ${#missing[@]} -ne 0 ]; then
        printf "${RED}❌ [FAIL]  Missing command(s): ${missing[*]}${NC}\n"
        exit 1
    else
        printf "${GREEN}✅ [OK]    All required commands are installed.${NC}\n"
    fi
}

check_all_commands
