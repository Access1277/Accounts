#!/bin/bash

# DNSTT Nameserver & Domain A Record
DNS_SERVER='ns.dnstt.lantindns.tech'
DOMAIN='dnstt.lantindns.tech'

# Repeat dig cmd loop time (seconds)
LOOP_DELAY=10

# DNS Hosts to check
declare -a DNS_HOSTS=('124.6.181.12' '8.8.8.8')

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
# If set to CUSTOM, enter your custom dig executable path here
CUSTOM_DIG="/data/data/com.termux/files/home/go/bin/fastdig"

case "${DIG_EXEC}" in
  DEFAULT|D)
    DIG_CMD="$(command -v dig)"
    ;;
  CUSTOM|C)
    DIG_CMD="${CUSTOM_DIG}"
    ;;
esac

if [ ! -x "${DIG_CMD}" ]; then
  printf "Error: Dig command not found or not executable. Please install dig(dnsutils) or check DIG_EXEC and CUSTOM_DIG variables.\n" >&2
  exit 1
fi

# Simple DNS Cache
declare -A DNS_CACHE

# Function to log messages to file and console
log_message() {
  local message="$1"
  local timestamp="$(date +"%Y-%m-%d %H:%M:%S")"

  echo "[${timestamp}] ${message}" | tee -a "${LOG_FILE}"
}

endscript() {
  log_message "Script terminated."
  exit 1
}

trap endscript 2 15

check_dns() {
  local target="$1"
  local retries=0

  # Check DNS Cache first
  if [ -n "${DNS_CACHE[$target]}" ]; then
    log_message "${target}: Cached DNS query successful."
    return 0
  fi

  while [ "${retries}" -lt "${MAX_RETRIES}" ]; do
    if "${DIG_CMD}" +timeout="${DIG_TIMEOUT}" @"${target}" "${DOMAIN}" 2>&1; then
      log_message "${target}: DNS query successful."
      DNS_CACHE["$target"]="success"
      return 0
    else
      log_message "${target}: DNS query failed (Attempt: $((retries + 1)))."
      retries=$((retries + 1))
      sleep 1
    fi
  done

  log_message "${target}: DNS query failed after ${MAX_RETRIES} attempts."
  DNS_CACHE["$target"]="failure"
  return 1
}

# Function to check DNS for all hosts in parallel
check() {
  local i
  for ((i=0; i<"${#DNS_HOSTS[@]}"; i++)); do
    check_dns "${DNS_HOSTS[$i]}" &
  done
  wait
}

echo "DNSTT Keep-Alive script <Lantin Nohanih>"
echo -e "DNS List: [\e[1;34m${DNS_HOSTS[*]}\e[0m]"
echo "Press CTRL + C to stop the script."

# Start looping
[[ "${LOOP_DELAY}" -eq 1 ]] && ((LOOP_DELAY++))
while true; do
  check
  echo "$(date +"%Y-%m-%d %H:%M:%S"): .--. .-.. . .- ... .     .-- .- .. -"
  sleep "${LOOP_DELAY}"
done
