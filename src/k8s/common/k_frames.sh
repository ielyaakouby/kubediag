#!/usr/bin/bash


frame_message_namespace_selected() {
    NAMESPACE="$1"
    if [[ -z $NAMESPACE ]]; then
        NAMESPACE=$(select_namespace) || exit 1
        if [[ -z $NAMESPACE  ]]; then
            echo "namespace is empty. Exiting..."
            return 1
        fi
        frame_message_1 "${GREEN}" "[✓] Selected Namespace: $NAMESPACE"
    fi
}

frame_message_1() {
    local color=$1; shift
    echo -e "${color}$*${NC}"
}


print_separator() {
    echo -e "${YELLOW}──────────────────────────────────────────────${NC}"
}


#frame_message() { echo -e "${1}${2}${RESET}"; }
#print_separator() { printf "\n%s\n" "${CYAN}──────────────────────────────────────────────${RESET}"; }


print_separator_with_date() {
    echo -e "${YELLOW}$(date '+%Y/%m/%d at %H:%M:%S') <---------------------------|${NC}"
}

print_full_line() {
    local char="${1:-*}"  # Default character is '*'
    printf '%*s\n' "$(tput cols)" '' | tr ' ' "$char"
}