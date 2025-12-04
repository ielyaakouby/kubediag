#!/usr/bin/bash

get_pods_corresponding_service() {
    NAMESPACE="$1"
    POD_NAME="$1"
    if [[ -z "$POD_NAME" ]] || [[ -z $NAMESPACE ]]; then
        NAMESPACE=$(select_namespace) || exit 1
        POD_NAME=$(select_pod "$NAMESPACE") || exit 1
        if [[ -z $NAMESPACE || -z "$POD_NAME" ]]; then
            echo "namespace and/or pod name is empty. Exiting..."
            return 1
        fi
        frame_message_1 "${GREEN}" "[✓] Selected Namespace: $NAMESPACE"
        frame_message_1 "${GREEN}" "[✓] Selected Pod: $POD_NAME"
    fi

    if [[ -z "$POD_NAME" ]]; then
        echo -e "${RED}Pod name is empty. Exiting...${RESET}"
        return 1
    fi

    echo -e "\n${BLUE}Labels for Pod '$POD_NAME':${RESET}"
    label_string=$(kubectl -n "${NAMESPACE}" get pod "${POD_NAME}" --show-labels --no-headers 2>/dev/null | awk '{print $NF}' | tr -d '{}"')

    if [[ -z "$label_string" ]]; then
        echo -e "${RED}No labels found for pod ${POD_NAME} in namespace ${NAMESPACE}.${RESET}"
        return 1
    fi

    # Find the corresponding services
    echo -e "${YELLOW}Finding the corresponding services for pod '$POD_NAME'...${RESET}"

    # Retrieve unique services based on pod labels
    echo "$label_string" | tr ',' '\n' | while read -r label; do
        kubectl -n "${NAMESPACE}" get services --no-headers -l "$label" 2>/dev/null | awk '{print $1}' | sort -u
    done | sort -u | while read -r service; do
        service_url="${service}.${NAMESPACE}.svc.cluster.local"
        echo -e "${GREEN}Found service:${RESET} ${service} -> ${service_url}"
    done
}
