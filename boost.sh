#!/bin/bash

TARGET_IP="124.6.181.12"
PING_INTERVAL=60
LOG_FILE="/path/to/log.txt"

while true; do
    ping -c 1 $TARGET_IP > /dev/null
    if [ $? -eq 0 ]; then
        echo "Ping to $TARGET_IP successful at $(date)" >> $LOG_FILE
    else
        echo "Ping to $TARGET_IP failed at $(date)" >> $LOG_FILE
        # Add additional actions like sending an email or triggering a reconnect
        # Example: mail -s "IP Keep-Alive Failure" your_email@example.com < $LOG_FILE
    fi
    sleep $PING_INTERVAL
done
