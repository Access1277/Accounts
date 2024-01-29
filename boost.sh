#!/bin/bash

# Define the loop delay in seconds
LOOP_DELAY=3

# Define the aligned nameservers and hosts
declare -A SERVERS=(
    ["sdns.myudph.elcavlaw.com"]="124.6.181.4 124.6.181.36 124.6.181.12"
)

# Linux' dig command executable filepath
# Select value: "CUSTOM|C" or "DEFAULT|D"
DIG_EXEC="DEFAULT"

# If set to CUSTOM, enter your custom dig executable path here
CUSTOM_DIG=/data/data/com.termux/files/home/go/bin/fastdig

VER=0.2

# Function to clean up and exit
endscript() {
    unset LOOP_DELAY SERVERS _DIG DIG_EXEC T R M
    exit 0
}

# Trap signals for graceful termination
trap endscript SIGINT SIGTERM

# Function to perform DNS checks
check() {
    for server in "${!SERVERS[@]}"; do
        for host in ${SERVERS["$server"]}; do
            T="${host}"
            R="${server}"

            # Background tasks: ping and host lookup
            (ping -c 1 "${T}" &)
            (host "${R}" &)

            # Perform DNS query with a timeout
            timeout -k 3 3 ${_DIG} @${T} "${R}" &

            # Check the exit status of the last command
            if [ $? -eq 0 ]; then
                M=32  # Green color for success
            else
                M=31  # Red color for failure
            fi
            echo -e "\e[${M}m:${R} D:${T}\e[0m"
        done
    done
}

echo "Enhanced DNSTT Keep-Alive script v${VER} <Discord @civ3>"
echo "DNS List:"
for server in "${!SERVERS[@]}"; do
    echo -e "\e[34m${server}\e[0m -> ${SERVERS["$server"]}"
done
echo "CTRL + C to close script"

# Ensure LOOP_DELAY is at least 1
if [ "${LOOP_DELAY}" -le 0 ]; then
    LOOP_DELAY=1
fi

# Main loop for continuous checks
while true; do
    check
    echo '.--. .-.. . .- ... .     .-- .- .. -'
    sleep ${LOOP_DELAY}
done
