#!/bin/bash
backupOrac.sh

REMOTE_IP=orac

UNISON_ARGUMENTS=()
UNISON_ARGUMENTS+=(/home/chrisl8/Dev/Orac)
UNISON_ARGUMENTS+=(ssh://"${REMOTE_IP}"//home/chrisl8/Orac)
UNISON_ARGUMENTS+=(-ignore "Path node/node_modules") # These are different on Pi and x86
UNISON_ARGUMENTS+=(-ignore "Path .idea")
UNISON_ARGUMENTS+=(-ignore "Path website-source")
UNISON_ARGUMENTS+=(-ignore "Path venv")
UNISON_ARGUMENTS+=(-auto)

if unison "${UNISON_ARGUMENTS[@]}"; then
  unison "${UNISON_ARGUMENTS[@]}" -batch -repeat watch
fi
