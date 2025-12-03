#!/usr/bin/bash

get_nodes_list_sort_by_age() {
    # kubectl get nodes -owide --sort-by='.metadata.creationTimestamp'
    kubectl get nodes  | awk 'NR==1{print;next} 
    {
        age = $4;
        days = 0; hours = 0; minutes = 0;
        
        # Extract days if present
        if (age ~ /[0-9]+d/) {
            split(age, d, "d");
            days = d[1];
            age = d[2];
        }
        
        # Extract hours if present
        if (age ~ /[0-9]+h/) {
            split(age, h, "h");
            hours = h[1];
            age = h[2];
        }
        
        # Extract minutes if present
        if (age ~ /[0-9]+m/) {
            split(age, m, "m");
            minutes = m[1];
        }

        # Calculate total age in minutes
        total_age = days * 1440 + hours * 60 + minutes;
        print $0, total_age;
    }' | sort -k6,6n | awk '{$NF=""; print $0}' | column -t

}

# Display node taints
