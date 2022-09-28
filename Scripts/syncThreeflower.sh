#!/bin/bash
REMOTE_IP=192.168.1.118


function copyArlobotDotFiles() {
  unison "${HOME}"/Dev/ArlobotDotfiles/threeflower ssh://${REMOTE_IP}/"${HOME}" -path .arlobot -auto
}

copyArlobotDotFiles

UNISON_ARGUMENTS=()
UNISON_ARGUMENTS+=("${HOME}")
UNISON_ARGUMENTS+=(ssh://"${REMOTE_IP}"/"${HOME}")
UNISON_ARGUMENTS+=(-path catkin_ws/src/ArloBot)
# Unlike Twoflower Threeflower is a force overwrite of the remote.
UNISON_ARGUMENTS+=(-force "${HOME}")

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

copyArlobotDotFiles
