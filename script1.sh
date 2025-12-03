#!/bin/bash

echo "Baciu Vlad-Robert"

valid_ipv4() {
    local ip="$1"
    if [[ ! "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then return 1; fi
    for octet in ${ip//./ }; do
        if [[ "${#octet}" -gt 1 && "${octet:0:1}" == 0 ]] || [[ "$octet" -gt 255 ]]; then return 1; fi
    done
    return 0
}

check_dns_association() {
    local host="$1"
    local ip="$2"
    local dns_srv="$3"

    if [[ "$host" == "localhost" ]]; then return 0; fi

    resolved_ip=$(nslookup "$host" "$dns_srv" 2>/dev/null | grep "Address: " | tail -n 1 | awk '{print $2}')

    if [[ -z "$resolved_ip" ]]; then
        echo "   -> [DNS FAIL] Could not resolve $host using server $dns_srv"
        return 1
    fi

    if [[ "$ip" != "$resolved_ip" ]]; then
        echo "   -> [BOGUS IP] File says $ip, but DNS says $resolved_ip"
        return 1
    else
        echo "   -> [VERIFIED] $host matches $ip"
        return 0
    fi
}

DNS_SERVER="8.8.8.8"

while read -r file_ip host_name aliases; do
    
    if [[ "$file_ip" == \#* ]] || [[ -z "$file_ip" ]]; then continue; fi

    if valid_ipv4 "$file_ip"; then
        echo "Checking $host_name ($file_ip)..."
        
        check_dns_association "$host_name" "$file_ip" "$DNS_SERVER"
    else
        echo "[INVALID SYNTAX] Skipping $file_ip - bad format."
    fi

done < /etc/hosts
