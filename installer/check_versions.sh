#!/usr/bin/env bash

CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

print_versions() {
    local REQUIRED_COMMANDS
    REQUIRED_COMMANDS=("git" "curl" "bash" "fzf")

    echo -e "[i] ${CYAN}Checking tool versions...${NC}"
    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        if command -v "$cmd" >/dev/null 2>&1; then
            version_output=$("$cmd" --version 2>&1 | head -n 1)

            # Extraire juste la version avec une expression adaptée
            case "$cmd" in
                git)
                    version=$(echo "$version_output" | awk '{print $3}')
                    ;;
                curl)
                    version=$(echo "$version_output" | awk '{print $2}')
                    ;;
                bash)
                    version=$(echo "$version_output" | grep -oP 'version\s+\K[0-9\.]+')
                    ;;
                fzf)
                    version=$("$cmd" --version | head -n1 | awk '{print $1}')
                    ;;
                *)
                    version="unknown"
                    ;;
            esac

            printf "  ▪ %-15s → %s\n" "$cmd" "$version"
        else
            printf "  ❌ %-15s → %s\n" "$cmd" "Command not found"
        fi
    done
}

print_versions