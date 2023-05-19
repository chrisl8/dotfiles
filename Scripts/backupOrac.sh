#!/bin/bash

set -e

UNISON_ARGUMENTS=()

UNISON_ARGUMENTS+=(/home/chrisl8/Dev/Orac)
UNISON_ARGUMENTS+=(/mnt/d/Dropbox/BACKUPS/Orac)
UNISON_ARGUMENTS+=(-force /home/chrisl8/Dev/Orac)
UNISON_ARGUMENTS+=(-perms 0)
UNISON_ARGUMENTS+=(-dontchmod)
UNISON_ARGUMENTS+=(-rsrc false)
UNISON_ARGUMENTS+=(-auto)
UNISON_ARGUMENTS+=(-links ignore)
UNISON_ARGUMENTS+=(-ignore "Name .vscode-server")
UNISON_ARGUMENTS+=(-ignore "Name node_modules")
UNISON_ARGUMENTS+=(-ignore "Name .idea")
UNISON_ARGUMENTS+=(-ignore "Name venv")
UNISON_ARGUMENTS+=(-ignore "Name .git") # If I exclude this, I lose git history for non-github repositories, but this is MOST of the churn, so doing it anyway.

if [[ -d /mnt/d/Dropbox/BACKUPS/Orac ]]; then
  printf "\n${YELLOW}Backing up to Dropbox.${NC}\n"
  unison "${UNISON_ARGUMENTS[@]}"

fi
