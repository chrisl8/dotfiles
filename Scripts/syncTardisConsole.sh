#!/bin/bash
REMOTE_IP=TARDIS-Console

scp "${REMOTE_IP}":/home/chrisl8/PanicStations/gamePlayStats.sqlite /mnt/d/Dropbox/BACKUPS/TardisConsole
scp "${REMOTE_IP}":/home/chrisl8/PanicStations/server.sqlite /mnt/d/Dropbox/BACKUPS/TardisConsole

scp "${REMOTE_IP}":/home/chrisl8/PanicStations/settings.json5 /home/chrisl8/Dev/PanicStations/exampleSettings/TardisConsole.json5

UNISON_ARGUMENTS=()
UNISON_ARGUMENTS+=(/home/chrisl8/Dev/PanicStations)
UNISON_ARGUMENTS+=(ssh://"${REMOTE_IP}"//home/chrisl8/PanicStations)
UNISON_ARGUMENTS+=(-ignore "Path node_modules") # These are different on Pi and x86
UNISON_ARGUMENTS+=(-ignore "Path .idea")
UNISON_ARGUMENTS+=(-ignore "Path settings.json5")
UNISON_ARGUMENTS+=(-ignore "Path gamePlayStats.sqlite")
UNISON_ARGUMENTS+=(-ignore "Path server.sqlite")
UNISON_ARGUMENTS+=(-auto)

if unison "${UNISON_ARGUMENTS[@]}"; then
  unison "${UNISON_ARGUMENTS[@]}" -batch -repeat watch
fi
