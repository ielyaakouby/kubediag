#!/usr/bin/bash

get_contexts() {
    kubectl config get-contexts -o=name
}

select_context() {
    local contexts
    contexts=$(get_contexts)
    echo "$contexts" | fzf --height 40% --border --prompt="🎯 Select context: "
}