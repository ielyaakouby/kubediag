#!/usr/bin/env bash

define_colors() {
    colors=(
        "\033[0;31m" "\033[0;32m" "\033[0;33m" "\033[0;34m"
        "\033[0;35m" "\033[0;36m" "\033[0;37m" "\033[1;34m"
        "\033[1;32m" "\033[1;33m" "\033[1;36m" "\033[1;33m"
        "\033[1;31m"
    )
    reset="\033[0m"
}

frame_message() {
    local color="$1"
    local message="$2"
    local RESET='\033[0m'
    echo -e "${color}${message}${RESET}"
}

create_temp_file() {
    local suffix="${1:-}"
    local tmp_file
    
    if [[ -n "$suffix" ]]; then
        tmp_file=$(mktemp --suffix="$suffix")
    else
        tmp_file=$(mktemp)
    fi
    
    if command -v register_temp_file &>/dev/null; then
        register_temp_file "$tmp_file"
    fi
    
    echo "$tmp_file"
}

choose_yaml_viewer() {
    local viewer
    viewer=$(printf "Cat (simple output)\nJless (terminal pager)\nVim (editor)\nKate (GUI editor)\nVSCode (GUI editor)\nGedit (GUI editor)" | fzf --prompt="▶ Select Viewer: " --height=40% | awk '{print tolower($1)}')
    echo "$viewer"
}

open_yaml_output() {
    local content_file="$1"
    local title="${2:-Kubernetes Output}"

    local viewer
    viewer=$(choose_yaml_viewer) || return 1

    frame_message "$GREEN" "Opening YAML file with $viewer..."

    case "$viewer" in
        "cat")         echo -e "\n--- YAML Content ---\n"; cat "$content_file"; echo -e "\n--- End of YAML ---\n" ;;
        "vim")         vim "$content_file" ;;
        "nano")        nano "$content_file" ;;
        "kate")        nohup kate -n "$content_file" &> /dev/null & ;;
        "jless")       gnome-terminal --title="$title" --geometry=180x45 -- bash -c "jless --yaml '$content_file'; echo ''; read" ;;
        "code"|"vscode") nohup code -n "$content_file" &> /dev/null & ;;
        "gedit")       nohup gedit "$content_file" &> /dev/null & ;;
        "notepadqq")   nohup notepadqq "$content_file" &> /dev/null & ;;
        *)             frame_message "$RED" "❌ Unrecognized viewer: $viewer. Cancelled."; return 1 ;;
    esac
}


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

kgp() {
    local args=()
    for arg in "$@"; do
        args+=("$(printf '%q' "$arg")")
    done
    kubectl get pods "${args[@]}"
}

#    local ns="$1"
#    local pod="$2"
#
#    [[ -z "$ns" ]] && ns=$(select_namespace)
#    [[ -z "$pod" ]] && pod=$(select_resource pod "$ns")
#
#
select_resource_() {
    local type="$1"
    local ns="$2"
    kubectl -n "$ns" get "$type" --no-headers | awk '{print $1}' | fzf --prompt="Select $type: "
}

select_resource() {
    local resource_type="$1"
    local resources
    if [[ -z $resource_type ]]; then
        echo "No resource type selected."
        exit 1
    fi
    
    resources=$(kubectl get "$resource_type" --all-namespaces --no-headers -o custom-columns=":metadata.name" 2>/dev/null)
    selected_resource=$(echo "$resources" | fzf --prompt="Select a $resource_type: ")
    
    echo "$selected_resource"
}


select_namespace() {
    local namespaces
    namespaces=$(kubectl get namespaces --no-headers -o custom-columns=":metadata.name" 2>/dev/null)
    selected_namespace=$(echo -e "all\n$namespaces" | fzf --prompt "📦 Select a namespace (or 'all'): ")

    if [[ -z "$selected_namespace" ]]; then
        frame_message "${RED}" "No namespace selected."
        return 1
    fi

    echo "$selected_namespace"
}

check_pod_status_for_logs() {
    local pod="$1"
    local namespace="$2"
    
    local pod_status
    pod_status=$(kubectl get pod "$pod" -n "$namespace" -o jsonpath='{.status.phase}' 2>/dev/null)
    
    if [[ "$pod_status" != "Running" ]]; then
        frame_message "$YELLOW" "⚠️  Pod '$pod' is not in Running state (current status: ${pod_status:-Unknown})"
        frame_message "$CYAN" "💡 Use 'kubectl describe pod $pod -n $namespace' to get more details about pod issues..."
        return 1
    fi
    return 0
}

select_resource_type() {
    local resource_type
    resource_type=$(kubectl api-resources --namespaced --no-headers | awk '{print $1}' | fzf --prompt="Select a resource type: ")
    if [[ -z "$resource_type" ]]; then
        echo "No resource type selected."
        return 1
    fi
    echo "$resource_type"
}

spinner() {
    local message="$1"
    local command="$2"
    local delay=0.1
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    eval "$command" &
    local pid=$!

    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i + 1) % ${#spin} ))
        printf "\r%s %s..." "${spin:$i:1}" "$message" >&2
        sleep "$delay"
    done

    wait "$pid"
    local exit_code=$?

    if [[ $exit_code -eq 0 ]]; then
        printf "\r\033[1;36m[✔] %s\033[0m\n" "$message" >&2
    else
        printf "\r\033[1;31m[✖] %s... failed\033[0m\n" "$message" >&2
    fi

    return "$exit_code"
}

check_snipp() {
    local message="$1"
    local command="$2"

    local delay=0.1
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    echo -n "⠿ $message... "

    spinner() {
        local pid="$1"
        while kill -0 "$pid" 2>/dev/null; do
            for ((i = 0; i < ${#spin}; i++)); do
                printf "\r%s %s..." "${spin:$i:1}" "$message"
                sleep "$delay"
            done
        done
    }

    eval "$command" &>/dev/null &
    local pid=$!

    spinner "$pid" &
    local spin_pid=$!

    wait "$pid"
    local exit_code=$?

    kill "$spin_pid" &>/dev/null
    wait "$spin_pid" 2>/dev/null

    if [ $exit_code -eq 0 ]; then
        printf "\r\033[1;36m[✓] %s... done\033[0m\n" "$message"
    else
        printf "\r\033[1;31m[✖] %s... failed\033[0m\n" "$message"
        exit 1
    fi
}

display_message() {
    local message_type="$1"
    local message="$2"
    case $message_type in
        red) echo -e "\033[31m$message\033[0m" ;;
        green) echo -e "\033[32m$message\033[0m" ;;
        *) echo "$message" ;;
    esac
}

cleanup() {
  [[ -f "$OK_FILE" ]] && rm -f "$OK_FILE"
  [[ -f "$NOK_FILE" ]] && rm -f "$NOK_FILE"
  [[ -f "$TMP_ALL_PODS" ]] && rm -f "$TMP_ALL_PODS"
  [[ -f "$TMP_NODE_REPORT" ]] && rm -f "$TMP_NODE_REPORT"
  [[ -f "$TMP_NODE_COUNTS" ]] && rm -f "$TMP_NODE_COUNTS"
}

calculate_time_and_end() {
    local duration=$1
    local start_time
    local current_time
    local elapsed_time
    start_time=$(date +%s)

    while true; do
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))

        if (( elapsed_time >= duration )); then
            echo "Time limit reached: $elapsed_time seconds."
            exit 0
        fi
        sleep 1
    done
}