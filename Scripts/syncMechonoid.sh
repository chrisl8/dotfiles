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

function copyDotFiles() {
  unison "${HOME}"/Dev/DotfilesForMechonoid/"${REMOTE_IP}" ssh://"${USER}"@"${REMOTE_IP}"//home/"${USER}" -path .mechonoid -auto
}

copyDotFiles

UNISON_ARGUMENTS=()
UNISON_ARGUMENTS+=("${HOME}"/Dev)
UNISON_ARGUMENTS+=(ssh://"${USER}"@"${REMOTE_IP}"//home/"${USER}")
UNISON_ARGUMENTS+=(-path Mechonoid)
UNISON_ARGUMENTS+=(-ignore "Name .idea")
UNISON_ARGUMENTS+=(-ignore "Name node/node_modules")
UNISON_ARGUMENTS+=(-ignore "Name website/node_modules")
UNISON_ARGUMENTS+=(-auto)

if unison "${UNISON_ARGUMENTS[@]}"; then
  # pigpio cannot install on a non-Pi box, but we need it for IntelliJ to code complete:
  if [[ -d "${HOME}"/Dev/Mechonoid/node/node_modules/ ]]; then
    scp -r "${USER}"@"${REMOTE_IP}":/home/"${USER}"/Mechonoid/node/node_modules/pigpio "${HOME}"/Dev/Mechonoid/node/node_modules/ >/dev/null
  fi

  unison "${UNISON_ARGUMENTS[@]}" -batch -repeat watch
fi

copyDotFiles
