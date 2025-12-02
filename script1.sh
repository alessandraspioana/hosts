#!/bin/bash

valid_ipv4() {
    local ip="$1"
    
    if [[ ! "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        return 1
    fi

    for octet in ${ip//./ }; do
        if [[ "${#octet}" -gt 1 && "${octet:0:1}" == 0 ]] || [[ "$octet" -gt 255 ]]; then
            return 1
        fi
    done
    
    return 0
}

while read -r file_ip host_name aliases; do
    
    if [[ "$file_ip" == \#* ]] || [[ -z "$file_ip" ]]; then 
        continue 
    fi

    if valid_ipv4 "$file_ip"; then
        echo "[SYNTAX OK] $file_ip ($host_name)"
    else
        echo "[SYNTAX ERROR] $file_ip is not a valid IP format!"
    fi

done < /etc/hosts