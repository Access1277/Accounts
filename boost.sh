#!/data/data/com.termux/files/usr/bin/bash

# DNS query booster and keepalive script for Termux

# Set your DNS server IP address
DNS_SERVER="124.6.181.12"

# Set the domain to query
DOMAIN="ns.dnstt.lantindns.tech"

# Set the interval for queries in seconds (e.g., 300 seconds for every 5 minutes)
QUERY_INTERVAL=300

# Set the timeout for each query in seconds (adjust according to your needs)
QUERY_TIMEOUT=5

# Function to perform DNS query
perform_dns_query() {
  result=$(termux-chroot dig +timeout=$QUERY_TIMEOUT $DOMAIN @$DNS_SERVER)
  echo "DNS Query Result: $result"
}

# Function to run DNS queries in a loop
dns_query_loop() {
  while true; do
    perform_dns_query
    sleep $QUERY_INTERVAL
  done
}

# Function to check the availability of the DNS server
check_dns_availability() {
  ping -c 1 $DNS_SERVER > /dev/null
  if [ $? -eq 0 ]; then
    echo "DNS Server is reachable."
  else
    echo "DNS Server is unreachable. Reconnecting..."
    # Add additional logic here for reconnection or handling failure
  fi
}

# Main execution
echo "DNS Query Booster and Keepalive Script for Termux"

# Check DNS server availability before starting the loop
check_dns_availability

# Start DNS query loop
dns_query_loop
