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
