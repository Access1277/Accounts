#!/bin/bash

clear

function endscript() {
  exit 1
}

trap endscript 2 15

get_name_servers() {
  read -ra NAME_SERVERS
  while [[ ${#NAME_SERVERS[@]} -eq 0 ]]; do
    echo "Please enter at least one NameServer. Enter again: "
    read -ra NAME_SERVERS
  done
}

echo "Enter Your NameServers separated by space: "
get_name_servers

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

check(){
  echo "============================="
  echo "LANTIN GTM Status Results"
  echo "============================="

  for R in "${NAME_SERVERS[@]}"; do
    result="$(grep -w "$R" /etc/hosts)"
    if [ -z "$result" ]; then
      STATUS="Failed"
    else
      STATUS="Success"
    fi
    echo "NameServer: $R"
    echo "Status: $STATUS"
    echo "Timestamp: $(date "+%Y-%m-%d %H:%M:%S")"
    echo "============================="

    # Log results to file
    echo "NameServer: $R" >> "$RESULTS_LOG"
    echo "Status: $STATUS" >> "$RESULTS_LOG"
    echo "Timestamp: $(date "+%Y-%m-%d %H:%M:%S")" >> "$RESULTS_LOG"
    echo "=============================" >> "$RESULTS_LOG"
  done

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
