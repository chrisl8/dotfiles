#!/usr/bin/env bash
REBOOT=false
SHUTDOWN=false
LINKNAME=$(basename "$0")

while test $# -gt 0
do
        case "$1" in
                --reboot) REBOOT=true
                ;;
                --restart) REBOOT=true
                ;;
                --shutdown) SHUTDOWN=true
                ;;
        *) echo "Invalid argument"
                exit
                ;;
        esac
        shift
done
CURRENT_GRAPHICS=$(prime-select query)
if [ "${CURRENT_GRAPHICS}" != "${LINKNAME}" ]; then
    sudo prime-select "${LINKNAME}"
    prime-select query
  if [[ "${REBOOT}" == "true" ]]; then
    sudo shutdown -r now
  fi
  if [[ "${SHUTDOWN}" == "true" ]]; then
    sudo shutdown -h now
  fi
fi

