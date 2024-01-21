#!/bin/bash

read -p "Enter the domain to query: " domain

# Perform DNS query
result=$(dig +short $domain)

# Display the result
if [ -n "$result" ]; then
    echo "DNS Result for $domain: $result"
else
    echo "No DNS records found for $domain"
fi

# Keep-alive
while true; do
    ping -c 1 google.com > /dev/null
    sleep 5  # Adjust the sleep duration as needed (300 seconds in this example)
done
