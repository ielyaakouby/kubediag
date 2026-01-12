#!/usr/bin/env bash

select_describe_resource_menu() {

    while true; do
        options=(
            "← Go Back"
            "? Describe Pod"
            "? Describe Service"
            "? Describe Ingress"
            "? Describe Deployment"
            "? Describe StatefulSet"
            "? Describe DaemonSet"
            "? Describe Node"
            "? Describe Others"
            "↑ Go Home"
        )

        local selected_action
        selected_action=$(printf "%s\n" "${options[@]}" | \
            fzf --prompt="Main Menu ❯ Describe Menu ❯ " \
                --header="➤ Kubernetes Resource Explorer - Choose what to describe" \
                --height=50% \
                --border=rounded \
                --no-mouse \
                --border-label="🩺 Kubernetes doctor 🩺" \
                --color="fg:#00FFFF,bg:#000000,hl:#00FF00,fg+:#FFFFFF,bg+:#000000,prompt:italic:green,border:blue,header:yellow")

        case $selected_action in
            *"Describe Pod")
                kubectl_describe_pod_config
                print_separator
                ;;
            *"Describe Service")
                kubectl_describe_service_config
                print_separator
                ;;
            *"Describe Ingress")
                kubectl_describe_ingress_config
                print_separator
                ;;
            *"Describe Deployment")
                kubectl_describe_deployment_config
                print_separator
                ;;
            *"Describe StatefulSet")
                kubectl_describe_statefulset_config
                print_separator
                ;;
            *"Describe DaemonSet")
                kubectl_describe_daemonset_config
                print_separator
                ;;
            *"Describe Node")
                kubectl_describe_node_config
                print_separator
                ;;
            *"Describe Others")
                kubectl_describe_any
                print_separator
                ;;
            *"Go Back") return 0 ;;
            *"Go Home") menu::select_main_action;;
            *)
                frame_message "${RED}" "Invalid option selected."
                ;;
        esac
    done
}
