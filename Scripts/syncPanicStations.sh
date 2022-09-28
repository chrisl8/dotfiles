#!/bin/bash
REMOTE_IP=192.168.1.22

UNISON_ARGUMENTS=()
UNISON_ARGUMENTS+=(/home/chrisl8/Dev/PanicStations)
UNISON_ARGUMENTS+=(ssh://pi@"${REMOTE_IP}"//home/pi/PanicStations)
#UNISON_ARGUMENTS+=(-ignore "Path node/node_modules") # Since I cannot install this locally, syncing them back is the best way to let IntelliJ see them
UNISON_ARGUMENTS+=(-ignore "Path .idea")
UNISON_ARGUMENTS+=(-auto)

if unison "${UNISON_ARGUMENTS[@]}"; then
  unison "${UNISON_ARGUMENTS[@]}" -ignore "Path node/node_modules" -batch -repeat watch
fi

scp pi@${REMOTE_IP}:/home/pi/PanicStations/node/statistics.csv "${HOME}"/Dropbox/PanicStations.csv
