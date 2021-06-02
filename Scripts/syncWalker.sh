#!/bin/bash
REMOTE_IP=walker1

UNISON_ARGUMENTS=()
UNISON_ARGUMENTS+=("${HOME}"/Dev)
UNISON_ARGUMENTS+=(ssh://ubuntu@"${REMOTE_IP}"//home/ubuntu)
UNISON_ARGUMENTS+=(-path RobotAnything)
UNISON_ARGUMENTS+=(-ignore "Name .idea")
UNISON_ARGUMENTS+=(-ignore "Name node/node_modules")
UNISON_ARGUMENTS+=(-ignore "Name website/node_modules")
UNISON_ARGUMENTS+=(-auto)
# Copying files to/from WSL2 screwed up perms.
# You can remove this and fix them, but it will take ages.
UNISON_ARGUMENTS+=(-perms=0)

if unison "${UNISON_ARGUMENTS[@]}"; then
  # pigpio cannot install on a non-Pi box, but we need it for IntelliJ to code complete:
  if [[ -d "${HOME}"/Dev/RobotAnything/node/node_modules/ ]]; then
    scp -r ubuntu@${REMOTE_IP}:/home/ubuntu/RobotAnything/node/node_modules/pigpio "${HOME}"/Dev/RobotAnything/node/node_modules/ >/dev/null
  fi

  unison "${UNISON_ARGUMENTS[@]}" -batch -repeat watch
fi
