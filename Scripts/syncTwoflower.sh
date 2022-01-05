#!/bin/bash
REMOTE_IP=twoflower

function copyArlobotDotFiles() {
  unison "${HOME}"/Dev/ArlobotDotfiles/${REMOTE_IP} ssh://ubuntu@"${REMOTE_IP}"//home/ubuntu -path .arlobot -auto
}

copyArlobotDotFiles

UNISON_ARGUMENTS=()
UNISON_ARGUMENTS+=("${HOME}")
UNISON_ARGUMENTS+=(ssh://ubuntu@"${REMOTE_IP}"//home/ubuntu)
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

copyArlobotDotFiles
