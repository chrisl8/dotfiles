#!/bin/bash
REMOTE_IP=192.168.1.157

UNISON_ARGUMENTS=()
UNISON_ARGUMENTS+=(/home/chrisl8/Dev/Orac)
UNISON_ARGUMENTS+=(ssh://"ovos@${REMOTE_IP}"//home/ovos/Orac)
UNISON_ARGUMENTS+=(-ignore "Path node/node_modules") # These are different on Pi and x86
UNISON_ARGUMENTS+=(-ignore "Path .idea")
UNISON_ARGUMENTS+=(-auto)

if unison "${UNISON_ARGUMENTS[@]}"; then
  unison "${UNISON_ARGUMENTS[@]}" -batch -repeat watch
fi
