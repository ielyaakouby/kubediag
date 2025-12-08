#!/usr/bin/bash


function ok_kubectl_exec_pod {
    # is_pod_ns_exit
    ensure_pod_and_namespace || return 1
    COMMAND="ls"
    if kubectl exec -n "$NAMESPACE" "$POD_NAME" -- which $COMMAND > /dev/null 2>&1; then
        echo "Executing $COMMAND in the container..."
        gnome-terminal --title="terminal - pods - $POD_NAME -namespace $NAMESPACE" --geometry=180x45 --tab -- bash -c "kubectl -n $NAMESPACE exec -it ${POD_NAME} -- /bin/sh; echo 'Type exit to close terminal'; exec /bin/bash"

    else
        echo "OCI runtime exec failed: exec failed: unable to start container process: exec: ls: executable file not found in \$PATH: unknown"
    fi        
}

function ok_k_exec_command {
    if [[ "$1" =~ ^(-h|--help|-help|help)$ ]]; then
        echo "Usage: ok_k_exec_command [COMMAND] [ARGS...]"
        echo
        echo "Examples:"
        echo "  ok_k_exec_command                # Opens an interactive shell in the pod"
        echo "  ok_k_exec_command ls -la         # Runs 'ls -la' inside the pod"
        echo "  ok_k_exec_command cat /etc/os-release  # Displays OS info inside the pod"
        return 0
    fi
    ensure_pod_and_namespace || return 1

    if [[ $# -eq 0 ]]; then
        COMMAND=(/bin/sh)
    else
        COMMAND=("$@")
    fi

    
    echo "Executing: $COMMAND in the container..."

    gnome-terminal --title="terminal - pods - $POD_NAME -namespace $NAMESPACE" --geometry=180x45 --tab -- bash -c "kubectl -n $NAMESPACE exec -it ${POD_NAME} -- $COMMAND; echo 'Type exit to close terminal'; exec /bin/bash"
}

kube_connect_to_pod() {
    local NAMESPACE
    NAMESPACE=$(select_namespace) || return 1

    local pod ns
    if [[ "$NAMESPACE" == "all" ]]; then
        local line
        line=$(kubectl get pods --all-namespaces --no-headers | awk '{print $2 " (ns:" $1 ")"}' | fzf --prompt="🔗 Select a pod to connect: ")
        [[ -z "$line" ]] && frame_message "$RED" "No pod selected." && return 1
        pod=$(echo "$line" | awk '{print $1}')
        ns=$(echo "$line" | sed -E 's/.*\(ns:([^)]*)\).*/\1/')
    else
        pod=$(select_pod "$NAMESPACE") || return 1
        ns="$NAMESPACE"
    fi
    echo -e "${YELLOW}🔗 Opening new terminal to connect to pod '${pod}' in namespace '${ns}'...${RESET}"

    local shell_cmd="/bin/sh"
    if kubectl exec -n \"$ns\" \"$pod\" -- ls /bin/bash &>/dev/null; then
        shell_cmd="/bin/bash"
    fi

    gnome-terminal \
        --title="K8s Connect → Pod: $pod | Namespace: $ns" \
        --geometry=180x45 \
        --maximize \
        -- bash -c "kubectl exec -it -n \"$ns\" \"$pod\" -- $shell_cmd; echo -e '\n${YELLOW}Session closed. Press ENTER to exit.${RESET}'; read"
}

