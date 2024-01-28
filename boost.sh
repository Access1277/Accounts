#!/bin/bash

clear

function endscript() {
  exit 1
}

trap endscript 2 15

get_dns_ips() {
  read -ra DNS_IPS
  while [[ ${#DNS_IPS[@]} -eq 0 ]]; do
    echo "Please enter at least one DNS IP. Enter again: "
    read -ra DNS_IPS
  done
}

get_name_servers() {
  read -ra NAME_SERVERS
  while [[ ${#NAME_SERVERS[@]} -eq 0 ]]; do
    echo "Please enter at least one NameServer. Enter again: "
    read -ra NAME_SERVERS
  done
}

echo "Enter DNS IPs separated by space: "
get_dns_ips

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

DIG_EXEC="DEFAULT"
CUSTOM_DIG=/data/data/com.termux/files/home/go/bin/fastdig
VER=0.3

case "${DIG_EXEC}" in
  DEFAULT|D)
    _DIG="$(command -v dig)"
    ;;
  CUSTOM|C)
    _DIG="${CUSTOM_DIG}"
    ;;
esac

if [ ! "$_DIG" ]; then
  printf "Dig command not found. Please install dig (dnsutils) or check the DIG_EXEC & CUSTOM_DIG variable.\n" && exit 1
fi

# Initialize the counter
count=1

RESULTS_LOG="dns_check_results.log"

check(){
  echo "============================="
  echo "LANTIN GTM Status Results"
  echo "============================="

  for T in "${DNS_IPS[@]}"; do
    for R in "${NAME_SERVERS[@]}"; do
      result="$($_DIG @"$T" "$R" +short)"
      if [ -z "$result" ]; then
        STATUS="Failed"
      else
        STATUS="Success"
      fi
      echo "DNS IP: $T"
      echo "NameServer: $R"
      echo "Status: $STATUS"
      echo "Timestamp: $(date "+%Y-%m-%d %H:%M:%S")"
      echo "============================="

      # Log results to file
      echo "DNS IP: $T" >> "$RESULTS_LOG"
      echo "NameServer: $R" >> "$RESULTS_LOG"
      echo "Status: $STATUS" >> "$RESULTS_LOG"
      echo "Timestamp: $(date "+%Y-%m-%d %H:%M:%S")" >> "$RESULTS_LOG"
      echo "=============================" >> "$RESULTS_LOG"
    done
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
