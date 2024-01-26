#!/bin/bash

NS='ns.dnstt.lantindns.tech'
A='dnstt.lantindns.tech'

LOOP_DELAY=1

declare -a HOSTS=('124.6.181.12')

DIG_EXEC="DEFAULT"
CUSTOM_DIG=/data/data/com.termux/files/home/go/bin/fastdig

DNS
BOOST_QUERIES=3

INITIAL_TTL=30

VER=0.9
case "${DIG_EXEC}" in
 DEFAULT|D)
 _DIG="$(command -v dig)"
 ;;
 CUSTOM|C)
 _DIG="${CUSTOM_DIG}"
 ;;
esac
if [ ! $(command -v ${_DIG}) ]; then
 printf "%b" "Dig command failed to run, " \
 "please install dig(dnsutils) or check " \
 "\$DIG_EXEC & \$CUSTOM_DIG variable inside $( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/$(basename "$0") file.\n" && exit 1
fi
endscript() {
 unset NS A LOOP_DELAY HOSTS _DIG DIG_EXEC CUSTOM_DIG T R M TTL
 exit 1
}
trap endscript 2 15
check(){
 for T in "${HOSTS[@]}"; do
  for R in "${NS}" "${A}"; do
   if [[ -z $(timeout -k 10 10 ${_DIG} @${T} ${R}) ]]; then
     M=31
     echo -e "\e[1;${M}m\$ R:${R} D:${T}\e[0m"
     echo "---------------------------------------"
   else
     M=32
     echo -e "\e[1;${M}m\$ R:${R} D:${T} - Connected!\e[0m"
     echo "---------------------------------------"
   fi
   unset R M
  done
 done
}

boost_dns() {
  for ((i=0; i<"${#HOSTS[@]}"; i++)); do
    for ((j=0; j<${BOOST_QUERIES}; j++)); do
      TTL=$((INITIAL_TTL + j))
      if ${_DIG} +short +ttl=${TTL} @${HOSTS[$i]} ${A} &>/dev/null; then
        echo "Boosted DNS query for ${HOSTS[$i]} - TTL: ${TTL} - Connected!"
      else
        echo "Boosted DNS query for ${HOSTS[$i]} - TTL: ${TTL}"
      fi
    done
    echo "---------------------------------------"
  done
  wait
}

echo "DNSTT Keep-Alive script <Lantin Nohanih>"
echo -e "DNS List: [\e[1;34m${HOSTS[*]}\e[0m]"
echo "CTRL + C to close script"
[[ "${LOOP_DELAY}" -eq 1 ]] && let "LOOP_DELAY++";

echo "Performing Keep-Alive..."
while true; do
  check
  echo '.--. .-.. . .- ... .     .-- .- .. -'
  sleep ${LOOP_DELAY}
done
