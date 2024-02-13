#!/bin/bash

# Configuration
readonly NS='ns.dnstt.lantindns.tech'
readonly A='dnstt.lantindns.tech'
readonly LOOP_DELAY=5
readonly RETRY_COUNT=3
readonly TIMEOUT=2
readonly LOG_FILE="dns_keep_alive.log"  # Change log file path as needed

# Array of hosts to query
declare -a HOSTS=('124.6.181.12')

# DNS executable
readonly DEFAULT_DIG="$(command -v dig)"
readonly CUSTOM_DIG="/data/data/com.termux/files/home/go/bin/fastdig"
DIG_EXEC="$DEFAULT_DIG"

# Check if custom DNS executable is available
if [ -x "$CUSTOM_DIG" ]; then
    DIG_EXEC="$CUSTOM_DIG"
fi

# Function to log messages
log_message() {
    local log_level=$1
    local message=$2
    echo "$(date +'%Y-%m-%d %H:%M:%S') [$log_level] $message" >> "$LOG_FILE"
}

# Create log file if it doesn't exist
touch "$LOG_FILE"  # This will create the log file if it doesn't exist

# Function to perform DNS queries
perform_query() {
    local host=$1
    local dns_server=$2
    local result
    for ((i=1; i<=RETRY_COUNT; i++)); do
        result=$("$DIG_EXEC" +timeout="$TIMEOUT" +retry="$i" "@$dns_server" "$host" 2>&1)
        if [ $? -eq 0 ]; then
            log_message "INFO" "Query successful - Host: $host, DNS Server: $dns_server"
            echo "$result"  # Output result to stdout
            return 0
        else
            log_message "ERROR" "Query failed - Host: $host, DNS Server: $dns_server, Attempt: $i, Error: $result"
        fi
    done
    log_message "ERROR" "All attempts failed - Host: $host, DNS Server: $dns_server"
    return 1
}

# Main function to check DNS status
check_dns() {
    for host in "${HOSTS[@]}"; do
        for dns_server in "$NS" "$A"; do
            echo "Querying $host using DNS server $dns_server..."
            perform_query "$host" "$dns_server"
            echo "----------------------------------"
        done
    done
}

# Trap SIGINT and SIGTERM signals
trap 'log_message "INFO" "Script terminated by user"; exit 1' SIGINT SIGTERM

# Main script
echo "Starting DNSTT Keep-Alive script (Version 2.1)"
echo "----------------------------------------------"
echo "DNS List: ${HOSTS[*]}"
echo "Loop Delay: ${LOOP_DELAY} seconds"
echo "Log File: $LOG_FILE"
echo "----------------------------------------------"

while true; do
    check_dns
    sleep "$LOOP_DELAY"
done
