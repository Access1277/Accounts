#!/bin/bash

CUSTOM_DIG="/data/data/com.termux/files/home/go/bin/fastdig"

# Function to query NS records
query_ns_records() {
    local domain="$1"
    echo "Querying NS records for $domain using $CUSTOM_DIG..."
    "$CUSTOM_DIG" +short NS "$domain"
}

# Function for DNS booster with keepalive
dns_booster() {
    echo "Starting DNS booster with keepalive..."
    # Add your DNS booster commands or logic here
}

# Example usage with the provided NS value
NS="sdns.myudph.elcavlaw.com"

# Query NS records for a specific domain using the provided NS value
query_ns_records "$NS"

# Uncomment the line below if you want to enable the DNS booster
# dns_booster
