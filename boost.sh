#!/bin/bash

function endscript() {
  echo -e "\nScript terminated."
  exit 1
}

trap endscript 2 15

LOOP_DELAY=5
echo -e "\e[1;37mCurrent loop delay is \e[1;33m${LOOP_DELAY}\e[1;37m seconds.\e[0m"

DIG_EXEC="DEFAULT"
CUSTOM_DIG=/path/to/custom/dig

case "${DIG_EXEC}" in
  DEFAULT|D)
    _DIG="$(command -v dig)"
    ;;
  CUSTOM|C)
    _DIG="${CUSTOM_DIG}"
    ;;
esac

if [ ! "$(command -v ${_DIG})" ]; then
  echo -e "\e[1;31mError: Dig command failed to run. Please install dig (dnsutils) or check the DIG_EXEC & CUSTOM_DIG variable.\e[0m"
  exit 1
fi

while true; do
  echo -e "\e[1;37mEnter a domain to query: \e[0m"
  read -r domain

  echo -e "\n\e[1;37mPerforming DNS query for \e[1;33m${domain}\e[0m"
  ${_DIG} +short "${domain}"

  echo -e "\n\e[1;37mEnter a host to ping: \e[0m"
  read -r host

  echo -e "\n\e[1;37mPinging \e[1;33m${host}\e[0m"
  ping -c 4 "${host}"

  sleep $LOOP_DELAY
done
