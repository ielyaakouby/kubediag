#!/usr/bin/bash

ok_k_pods_check() {

    echo -e "${YELLOW}--- Checking for non-running pods in all namespaces ---${RESET}"

    output=$(kubectl get po -A | grep -v "Running\|Complete")

    if [[ -z "$output" ]]; then
        echo -e "${GREEN}✅ All pods are in Running or Complete state.${RESET}"
    else
        echo -e "${RED}⚠️  Non-running pods detected:${RESET}"
        echo "$output" | awk '
            BEGIN {
                Yellow="\033[1;33m";
                Red="\033[1;31m";
                Cyan="\033[1;36m";
                Reset="\033[0m";
            }
            NR==1 { print Cyan $0 Reset; next }  # Colorize header
            {
                print Red $0 Reset;
            }'
    fi
}

get_node_name_of_pod() {
    ensure_pod_and_namespace || return 1
    kubectl get po "$POD_NAME" -n "$NAMESPACE"  2>/dev/null -o jsonpath='{.spec.nodeName}'
}

get_liveness_readiness_pod_orig() {
    ensure_pod_and_namespace || return 1
    frame_message "${BLUE}" "Readiness Probe:"
    kubectl get pod "$POD_NAME" -n "$NAMESPACE" 2>/dev/null -o yaml | grep -A 9 "readinessProbe:"
    frame_message "${BLUE}" "Liveness Probe:"
    kubectl get pod "$POD_NAME" -n "$NAMESPACE" 2>/dev/null -o yaml | grep -A 9 "livenessProbe:"
}

get_liveness_readiness_pod() {
    ensure_pod_and_namespace || return 1

    pod_yaml=$(kubectl get pod "$POD_NAME" -n "$NAMESPACE" -o yaml 2>/dev/null)
    if [ -z "$pod_yaml" ]; then
        echo -e "${YELLOW}Error:${RESET} Pod '$POD_NAME' not found in namespace '$NAMESPACE'."
        return 1
    fi

    readiness_probe=$(echo "$pod_yaml" | grep -A 9 "readinessProbe:")
    if [ -z "$readiness_probe" ]; then
        echo -e "${GREEN}No readiness probe set.${RESET}"
    else
        echo -e "${readiness_probe}"
    fi

    liveness_probe=$(echo "$pod_yaml" | grep -A 9 "livenessProbe:")
    if [ -z "$liveness_probe" ]; then
        echo -e "${GREEN}No liveness probe set.${RESET}"
    else
        echo -e "${liveness_probe}"
    fi
}