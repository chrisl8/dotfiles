#!/bin/bash
REMOTE_IP=192.168.1.53

function copyDotFiles() {
  unison "${HOME}"/Dev/ArlobotDotfiles/twoflower ssh://${REMOTE_IP}/"${HOME}" -path .arlobot -auto
}

copyDotFiles

UNISON_ARGUMENTS=()
UNISON_ARGUMENTS+=("${HOME}")
UNISON_ARGUMENTS+=(ssh://"${REMOTE_IP}"/"${HOME}")
UNISON_ARGUMENTS+=(-path catkin_ws/src/ArloBot)
UNISON_ARGUMENTS+=(-ignore "Name .idea")
UNISON_ARGUMENTS+=(-ignore "Name {*.pyc}")
UNISON_ARGUMENTS+=(-ignore "Name xscreen.png")
UNISON_ARGUMENTS+=(-ignore "Name xscreenOld.png")
UNISON_ARGUMENTS+=(-ignore "Name node_modules")
UNISON_ARGUMENTS+=(-ignore "Name mycroft-core")
UNISON_ARGUMENTS+=(-auto)

if unison "${UNISON_ARGUMENTS[@]}"; then
  unison "${UNISON_ARGUMENTS[@]}" -batch -repeat watch
fi

copyDotFiles
