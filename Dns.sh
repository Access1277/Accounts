#!/bin/bash

# Copyright ©UDPTeam
# Discord: https://discord.gg/civ3
# Script to keep-alive your DNSTT server domain record query from target resolver/local dns server
# Run this script excluded from your VPN tunnel (split VPN tunneling mode)
# Run command: ./globe-J_Kim.sh l
# Repeat dig command loop time (seconds) (positive integer only)
LOOP_DELAY=5

# Define the aligned nameservers and hosts
declare -A SERVERS=(
    ["ns.dnstt.lantindns.tech"]="124.6.181.12 124.6.181.4"
)

# Linux' dig command executable filepath
# Select value: "CUSTOM|C" or "DEFAULT|D"
DIG_EXEC="DEFAULT"

# If set to CUSTOM, enter your custom dig executable path here
CUSTOM_DIG=/data/data/com.termux/files/home/go/bin/fastdig

VER=0.1

case "${DIG_EXEC}" in
DEFAULT|D)
    _DIG="$(command -v dig)"
    ;;
CUSTOM|C)
    _DIG="${CUSTOM_DIG}"
    ;;
esac

if [ ! $(command -v ${_DIG}) ]; then
    printf "Dig command failed to run, please install dig (dnsutils) or check DIG_EXEC & CUSTOM_DIG variables inside $( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/$(basename "$0") file.\n"
    exit 1
fi

endscript() {
    unset LOOP_DELAY SERVERS _DIG DIG_EXEC T R M
    exit 1
}

trap endscript 2 15

check() {
    for server in "${!SERVERS[@]}"; do
        for host in ${SERVERS["$server"]}; do
            T="${host}"
            R="${server}"
            
            # Combine ping and host lookup into a single background command
            { ping -c 1 "${T}" & host "${R}" & } > /dev/null
            
            timeout -k 3 3 ${_DIG} @${T} "${R}" > /dev/null  # Remove the domain name
            if [ $? -eq 0 ]; then
                M=32
            else
                M=31
            fi
            echo -e "\e[${M}m:${R} D:${T}\e[0m"
        done &
    done
    wait  # Wait for all background processes to finish
}

echo "DNSTT Keep-Alive script <Discord @civ3>"
echo "DNS List:"
for server in "${!SERVERS[@]}"; do
    echo -e "\e[34m${server}\e[0m -> ${SERVERS["$server"]}"
done
echo "CTRL + C to close script"

if [ "${LOOP_DELAY}" -eq 1 ]; then
    let "LOOP_DELAY++"
fi

while true; do
    check
    echo '.--. .-.. . .- ... .     .-- .- .. -'
    sleep ${LOOP_DELAY}
done
