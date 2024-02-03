#!/bin/bash

# Modify these variables according to your setup
DNS_SERVER="124.6.181.12"
DNS_PORT="53"
LOCAL_PORT="1080"
TARGET_HOST="ns.dnstt.lantindns.tech"
TARGET_PORT="8080"

# Function to check if dnstt is running and start if necessary
check_and_start() {
    if ! pgrep -x "dnstt-client" > /dev/null; then
        dnstt-client -a "$DNS_SERVER:$DNS_PORT" -l "127.0.0.1:$LOCAL_PORT" -r "$TARGET_HOST:$TARGET_PORT" &
    fi
}

# Main loop for keep-alive
while true; do
    # Check and start dnstt if not running
    check_and_start

    # Sleep for a while before checking again
    sleep 30
done
