#!/bin/bash
# This is no longer used, as I now perform a regular full backup of WSL2 Home

set -e

UNISON_ARGUMENTS=()

UNISON_ARGUMENTS+=(/home/chrisl8/Dev/PanicStations)
UNISON_ARGUMENTS+=(/mnt/d/Dropbox/BACKUPS/PanicStations)
UNISON_ARGUMENTS+=(-force /home/chrisl8/Dev/PanicStations)
UNISON_ARGUMENTS+=(-perms 0)
UNISON_ARGUMENTS+=(-dontchmod)
UNISON_ARGUMENTS+=(-rsrc false)
UNISON_ARGUMENTS+=(-auto)
UNISON_ARGUMENTS+=(-batch)
UNISON_ARGUMENTS+=(-links ignore)
UNISON_ARGUMENTS+=(-ignore "Name .vscode-server")
UNISON_ARGUMENTS+=(-ignore "Name node_modules")
UNISON_ARGUMENTS+=(-ignore "Name .idea")
UNISON_ARGUMENTS+=(-ignore "Name venv")
UNISON_ARGUMENTS+=(-ignore "Name .git") # If I exclude this, I lose git history for non-github repositories, but this is MOST of the churn, so doing it anyway.

if [[ -d /mnt/d/Dropbox/BACKUPS/PanicStations ]]; then
  printf "\n${YELLOW}Backing up to Dropbox.${NC}\n"
  unison "${UNISON_ARGUMENTS[@]}"
fi
