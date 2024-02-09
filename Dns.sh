#!/bin/bash

clear

function endscript() {
  exit 1
}

trap endscript 2 15

echo -e "\e[1;37mEnter DNS IPs separated by ' ': \e[0m"
read -a DNS_IPS

echo -e "\e[1;37mEnter Your NameServers separated by ' ': \e[0m"
read -a NAME_SERVERS

echo -e "\e[1;37mEnter the timeout duration in seconds (default: 3): \e[0m"
read -r TIMEOUT_DURATION
TIMEOUT_DURATION=${TIMEOUT_DURATION:-3}

LOOP_DELAY=1
echo -e "\e[1;37mCurrent loop delay is \e[1;33m${LOOP_DELAY}\e[1;37m seconds.\e[0m"
echo -e "\e[1;37mWould you like to change the loop delay? \e[1;36m[y/n]:\e[0m "
read -r change_delay

if [[ "$change_delay" == "y" ]]; then
  echo -e "\e[1;37mEnter custom loop delay in seconds \e[1;33m(5-15):\e[0m "
  read -r custom_delay
  if [[ "$custom_delay" =~ ^[5-9]$|^1[0-5]$ ]]; then
    LOOP_DELAY=$custom_delay
  else
    echo -e "\e[1;31mInvalid input. Using default loop delay of ${LOOP_DELAY} seconds.\e[0m"
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

if [ ! $(command -v ${_DIG}) ]; then
  printf "%b" "Dig command failed to run, please install dig(dnsutils) or check the DIG_EXEC & CUSTOM_DIG variable.\n" && exit 1
fi

# Initialize the counter
count=1

check_dns() {
  local dns_ip=$1
  local nameserver=$2
  local result=$(${_DIG} @${dns_ip} ${nameserver} +short)
  if [ -z "$result" ]; then
    echo -e "DNS IP: ${dns_ip}, NameServer: ${nameserver}, Status: Failed"
  else
    echo -e "DNS IP: ${dns_ip}, NameServer: ${nameserver}, Status: Success, IP: ${result}"
  fi
}

check_all_dns() {
  for dns_ip in "${DNS_IPS[@]}"; do
    for nameserver in "${NAME_SERVERS[@]}"; do
      check_dns "$dns_ip" "$nameserver"
    done
  done
}

# Main loop
while true; do
  echo "Checking DNS statuses..."
  check_all_dns
  ((count++))  # Increment the counter
  sleep $LOOP_DELAY
done

exit 0
