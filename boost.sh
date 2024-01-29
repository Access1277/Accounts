#!/bin/bash

# Improved DNSTT Keep-Alive Script
# Copyright ©DAILYFreenet
# Recoded by: JAMES BLU

# Your DNSTT Nameservers
declare -a NAMESERVERS=('sdns.myudp.elcavlaw.com' 'sdns.myudph.elcavlaw.com')
# Your Domain `A` Record
A_RECORD='myudph.elcavlaw.com'

# Add your DNS here
declare -a HOSTS=('124.6.181.36' '124.6.181.20' '124.6.181.12' '112.198.115.44' '112.198.115.36' '112.198.115.60' '124.6.181.44' '124.6.181.4')

# Loop delay in seconds (positive integer only)
LOOP_DELAY=5
if ! [[ "$LOOP_DELAY" =~ ^[1-9][0-9]*$ ]]; then
    echo "Invalid LOOP_DELAY. Must be a positive integer."
    exit 1
fi

# Check and set the dig command
DIG_EXEC=${DIG_EXEC:-"DEFAULT"} # Use DEFAULT if not set
CUSTOM_DIG='/data/data/com.termux/files/home/go/bin/fastdig'

# Determine the dig command based on user choice
DIG_CMD=""
case "${DIG_EXEC}" in
    DEFAULT|D) DIG_CMD="$(command -v dig)" ;;
    CUSTOM|C) DIG_CMD="${CUSTOM_DIG}" ;;
    *) echo "Invalid DIG_EXEC value. Please choose DEFAULT or CUSTOM."; exit 1 ;;
esac

# Verify that dig command is available
if [ -z "${DIG_CMD}" ]; then
    echo "Dig command not found. Please install dnsutils or set the correct path in CUSTOM_DIG."
    exit 1
fi

# Function to end the script
function end_script() {
    echo "Exiting script."
    exit 0
}

# Trap SIGINT and SIGTERM
trap end_script SIGINT SIGTERM

# Function to check the DNS
function check_dns() {
    for host in "${HOSTS[@]}"; do
        for ns in "${NAMESERVERS[@]}" "${A_RECORD}"; do
            if [ -z "$(timeout -k 3 3 ${DIG_CMD} @${host} ${ns} 2> /dev/null)" ]; then
                echo "R:${ns} D:${host} - success"
            else
                echo "R:${ns} D:${host} - success"
            fi
        done
    done
}

# Main execution
echo "DNSTT Keep-Alive script Modified by: LANTIN"
echo "DNS List: ${HOSTS[*]}"
echo "CTRL + C to close script"

# Loop or single check based on argument
if [ "$1" == "loop" ] || [ "$1" == "l" ]; then
    echo "Script loop: ${LOOP_DELAY} seconds"
    while true; do
        check_dns
        echo 'LANTIN NOHANIH'
        sleep ${LOOP_DELAY}
    done
else
    check_dns
fi

exit 0
