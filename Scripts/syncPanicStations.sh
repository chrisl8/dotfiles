#!/bin/bash
backupPanicStations.sh

REMOTE_IP=PanicStations

UNISON_ARGUMENTS=()
UNISON_ARGUMENTS+=(/home/chrisl8/Dev/PanicStations)
UNISON_ARGUMENTS+=(ssh://"${REMOTE_IP}"//home/chrisl8/PanicStations)
UNISON_ARGUMENTS+=(-ignore "Path node/node_modules") # These are different on Pi and x86
UNISON_ARGUMENTS+=(-ignore "Path .idea")
UNISON_ARGUMENTS+=(-auto)

if unison "${UNISON_ARGUMENTS[@]}"; then
  unison "${UNISON_ARGUMENTS[@]}" -batch -repeat watch
fi
