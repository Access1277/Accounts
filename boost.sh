#!/bin/bash

# Your DNSTT Nameserver & your Domain `A` Record
NS='ns.dnstt.lantindns.tech'
A='dnstt.lantindns.tech'

# Repeat dig cmd loop time (seconds)
LOOP_DELAY=1

# Add your DNS here
declare -a HOSTS=('124.6.181.12')

# Number of parallel queries
PARALLEL_QUERIES=4

# Customizable timeout for dig command
DIG_TIMEOUT=5

# Maximum number of retry attempts
MAX_RETRIES=3

# Log file path
LOG_FILE="/var/log/dnstt_keepalive.log"

# Linux' dig command executable filepath
DIG_EXEC="DEFAULT"
# if set to CUSTOM, enter your custom dig executable path here
CUSTOM_DIG="/data/data/com.termux/files/home/go/bin/fastdig"

VER=0.4
case "${DIG_EXEC}" in
  DEFAULT|D)
    _DIG="$(command -v dig)"
    ;;
  CUSTOM|C)
    _DIG="${CUSTOM_DIG}"
    ;;
esac

if [ ! -x "${_DIG}" ]; then
  printf "Error: Dig command not found or not executable. Please install dig(dnsutils) or check DIG_EXEC and CUSTOM_DIG variables.\n" >&2
  exit 1
fi

endscript() {
  unset NS A LOOP_DELAY PARALLEL_QUERIES DIG_TIMEOUT MAX_RETRIES HOSTS _DIG DIG_EXEC CUSTOM_DIG T R M
  exit 1
}

trap endscript 2 15

check_dns() {
  local target=$1
  local result
  local retries=0

  while [ "${retries}" -lt "${MAX_RETRIES}" ]; do
    result=$("${_DIG}" +timeout="${DIG_TIMEOUT}" @"${target}" "${A}" 2>&1)
    if [ $? -eq 0 ]; then
      echo -e "\e[1;32m${target}: DNS query successful\e[0m"
      echo "${target}: DNS query successful" >> "${LOG_FILE}"
      return 0
    else
      echo -e "\e[1;31m${target}: DNS query failed (Attempt: $((retries + 1)))\e[0m"
      echo "${target}: DNS query failed (Attempt: $((retries + 1)))" >> "${LOG_FILE}"
      retries=$((retries + 1))
      sleep 1  # Adjust the delay between retries if needed
    fi
  done

  echo -e "\e[1;31m${target}: DNS query failed after ${MAX_RETRIES} attempts\e[0m"
  echo "${target}: DNS query failed after ${MAX_RETRIES} attempts" >> "${LOG_FILE}"
  return 1
}

# Function to check DNS for all hosts in parallel
check() {
  local i
  for ((i=0; i<"${#HOSTS[@]}"; i++)); do
    check_dns "${HOSTS[$i]}" &
  done
  wait
}

echo "DNSTT Keep-Alive script <Lantin Nohanih>"
echo -e "DNS List: [\e[1;34m${HOSTS[*]}\e[0m]"
echo "CTRL + C to close script"

# Start looping
[[ "${LOOP_DELAY}" -eq 1 ]] && ((LOOP_DELAY++))
case "${@}" in
  loop|l)
    echo "Script loop: ${LOOP_DELAY} seconds"
    while true; do
      check
      echo '.--. .-.. . .- ... .     .-- .- .. -'
      sleep "${LOOP_DELAY}"
    done
    ;;
  *)
    check
    ;;
esac

exit 0
