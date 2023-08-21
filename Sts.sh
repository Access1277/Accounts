NS='ns.gtmsdns.bagito.tech'
A='gtmsdns.bagito.tech'
LOOP_DELAY=5

declare -a HOSTS=('dnsts.bagito.tech')
DIG_EXEC="DEFAULT"

CUSTOM_DIG=/data/data/com.termux/files/home/go/bin/fastdig

######################################
######################################
######################################
######################################
######################################
VER=0.1
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
 unset NS A LOOP_DELAY HOSTS _DIG DIG_EXEC CUSTOM_DIG T R M
 exit 1
}
trap endscript 2 15
check(){
 for ((i=0; i<"${#HOSTS[*]}"; i++)); do
  for R in "${NS}" "${A}"; do
   T="${HOSTS[$i]}"
     $(timeout -k .3 .3 ${_DIG} @${T} ${R})  && M=31 || M=32;
   echo -e "\e[1;${M}m\$ R:${R} D:${T}\e[0m"
   unset T R M
  done
 done
}
echo "DNSTT Keep-Alive script <Discord @civ3>"
echo -e "DNS List: [\e[1;34m${HOSTS[*]}\e[0m]"
echo "CTRL + C to close script"
 "${LOOP_DELAY}" -eq 1  && let "LOOP_DELAY++";
case "${@}" in
 loop|l)
 echo "Script loop: ${LOOP_DELAY} seconds"
 while true; do
  check
  echo '.--. .-.. . .- ... .     .-- .- .. -'
  sleep ${LOOP_DELAY}
 done
 ;;
 *)
 check
 ;;
esac
exit 0
