#!/usr/bin/bash

troubleshooting_run_tool() {
    local tool_name="$1"
    local image="${2:-busybox}"

    local namespace
    namespace=$(select_namespace) || exit 1

    if [[ "$namespace" == "all" ]]; then
        frame_message "${RED}" "❌ Cannot run '$tool_name' pod in 'all' namespaces. Please select a specific namespace."
        return 1
    fi

    gnome-terminal \
        --title="Troubleshooting run $tool_name in pod $tool_name-test - namespace: $namespace" \
        --geometry=180x45 \
        -- bash -c "echo '[✓] Running $tool_name-test in namespace: $namespace'; \
                    kubectl run $tool_name-test --rm -it -n \"$namespace\" --image=$image -- sh 2>/dev/null || echo '❌ Failed to start $tool_name-test pod.'; \
                    exec bash"
}

troubleshooting_run_curl()     { troubleshooting_run_tool "curl" "curlimages/curl"; }
troubleshooting_run_ping()     { troubleshooting_run_tool "ping"; }
troubleshooting_run_wget()     { troubleshooting_run_tool "wget"; }
troubleshooting_run_telnet()   { troubleshooting_run_tool "telnet"; }
troubleshooting_run_nslookup() { troubleshooting_run_tool "nslookup"; }
