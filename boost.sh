#!/bin/bash

clear

function endscript() {
  exit 1
}

trap endscript 2 15

LOOP_DELAY=5
echo "Current loop delay is ${LOOP_DELAY} seconds."
read -p "Would you like to change the loop delay? [y/n]: " change_delay

if [[ "$change_delay" == "y" ]]; then
  read -p "Enter custom loop delay in seconds (5-15): " custom_delay
  if [[ "$custom_delay" =~ ^[5-9]$|^1[0-5]$ ]]; then
    LOOP_DELAY=$custom_delay
  else
    echo "Invalid input. Using default loop delay of ${LOOP_DELAY} seconds."
  fi
fi

# Initialize the counter
count=1

RESULTS_LOG="dns_check_results.log"

NAMESERVERS_URL="https://raw.githubusercontent.com/Access1277/Accounts/main/nameservers.txt"

check(){
  echo "============================="
  echo "LANTIN GTM Status Results"
  echo "============================="

  while IFS= read -r nameserver; do
    result="$(grep -w "$nameserver" /etc/hosts)"
    if [ -z "$result" ]; then
      STATUS="Failed"
    else
      STATUS="Success"
    fi
    echo "NameServer: $nameserver"
    echo "Status: $STATUS"
    echo "Timestamp: $(date "+%Y-%m-%d %H:%M:%S")"
    echo "============================="

    # Log results to file
    echo "NameServer: $nameserver" >> "$RESULTS_LOG"
    echo "Status: $STATUS" >> "$RESULTS_LOG"
    echo "Timestamp: $(date "+%Y-%m-%d %H:%M:%S")" >> "$RESULTS_LOG"
    echo "=============================" >> "$RESULTS_LOG"
  done < <(curl -s "$NAMESERVERS_URL")

  echo "Check count: $count"
  echo "Loop Delay: $LOOP_DELAY seconds"

  # Increment the counter
  ((count++))
}

countdown() {
  for i in {2..1}; do
    echo "Checking started in $i seconds..."
    sleep 1
  done
}

echo ""
countdown
clear

# Main loop
while true; do
  check
  sleep "$LOOP_DELAY"
done

exit 0
