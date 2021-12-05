#!/bin/bash
REMOTE_IP=""

while test $# -gt 0; do
  REMOTE_IP=$1
  shift
done

if [[ "${REMOTE_IP}" == "" ]]; then
  echo "You must provide a hostname."
  exit
fi

function copyArlobotDotFiles() {
  unison "${HOME}"/Dev/ArlobotDotfiles/"${REMOTE_IP}" ssh://ubuntu@"${REMOTE_IP}"//home/ubuntu -path .arlobot -auto
}

copyArlobotDotFiles

UNISON_ARGUMENTS=()
UNISON_ARGUMENTS+=("${HOME}")
UNISON_ARGUMENTS+=(ssh://ubuntu@"${REMOTE_IP}"//home/ubuntu)
UNISON_ARGUMENTS+=(-path catkin_ws/src/ArloBot)
# Unlike Twoflower, this is a force overwrite of the remote.
UNISON_ARGUMENTS+=(-force "${HOME}")
UNISON_ARGUMENTS+=(-perms 0)

UNISON_ARGUMENTS+=(-ignore "Name .git")
UNISON_ARGUMENTS+=(-ignore "Name .idea")
UNISON_ARGUMENTS+=(-ignore "Name {*.pyc}")
UNISON_ARGUMENTS+=(-ignore "Name xscreen.png")
UNISON_ARGUMENTS+=(-ignore "Name xscreenOld.png")
UNISON_ARGUMENTS+=(-ignore "Name node_modules")
UNISON_ARGUMENTS+=(-ignore "Name .eslintcache")
UNISON_ARGUMENTS+=(-ignore "Name __pycache__")
UNISON_ARGUMENTS+=(-ignore "Name mycroft-core")
UNISON_ARGUMENTS+=(-ignore "Name website/build")
UNISON_ARGUMENTS+=(-ignore "Name PropellerCodeForArloBot/ROSInterfaceForArloBot/bin")
UNISON_ARGUMENTS+=(-ignore "Name PropellerCodeForArloBot/2ndBoardCode/bin")
UNISON_ARGUMENTS+=(-ignore "Name PropellerCodeForArloBot/Calib/bin")
UNISON_ARGUMENTS+=(-ignore "Name PropellerCodeForArloBot/MotorResponseTesting/bin")
UNISON_ARGUMENTS+=(-auto)

if unison "${UNISON_ARGUMENTS[@]}"; then
  unison "${UNISON_ARGUMENTS[@]}" -batch -repeat watch
fi

copyArlobotDotFiles
