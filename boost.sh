#!/bin/bash

NAMESERVER="sdns.myudph.elcavlaw.com"
DNS_QUERY="bugg.elcavlaw.com"
LOG_FILE="/path/to/dns_keep_alive.log"
PING_INTERVAL=60

while true; do
    nslookup $DNS_QUERY $NAMESERVER > /dev/null
    if [ $? -eq 0 ]; then
        echo "DNS lookup to $NAMESERVER for $DNS_QUERY successful at $(date)" >> $LOG_FILE
    else
        echo "DNS lookup to $NAMESERVER for $DNS_QUERY failed at $(date)" >> $LOG_FILE
        # Add additional actions like sending an email or triggering a reconnect
        # Example: mail -s "Nameserver Keep-Alive Failure" your_email@example.com < $LOG_FILE
    fi
    sleep $PING_INTERVAL
done
