#!/bin/bash
# shellcheck disable=SC2059

UNISON_ARGUMENTS=()

UNISON_ARGUMENTS+=("${HOME}")
UNISON_ARGUMENTS+=(/mnt/c/Users/chris/Dropbox/BACKUPS/WSL2-Linux/home/chrisl8)
UNISON_ARGUMENTS+=(-force "${HOME}")
UNISON_ARGUMENTS+=(-perms 0)
UNISON_ARGUMENTS+=(-dontchmod)
UNISON_ARGUMENTS+=(-rsrc false)
UNISON_ARGUMENTS+=(-auto)
UNISON_ARGUMENTS+=(-links false)
UNISON_ARGUMENTS+=(-ignore "Name node_modules")
UNISON_ARGUMENTS+=(-ignore "Name .nvm")
UNISON_ARGUMENTS+=(-ignore "Name .zsh_history")
UNISON_ARGUMENTS+=(-ignore "Name unison.log")
UNISON_ARGUMENTS+=(-ignore "Name .cache")
UNISON_ARGUMENTS+=(-ignore "Name .keychain")
UNISON_ARGUMENTS+=(-ignore "Name .npm")
UNISON_ARGUMENTS+=(-ignore "Name .unison*")
UNISON_ARGUMENTS+=(-ignore "Name .docker")
UNISON_ARGUMENTS+=(-ignore "Name .ros")
UNISON_ARGUMENTS+=(-ignore "Name .idea")
UNISON_ARGUMENTS+=(-ignore "Name .git")
UNISON_ARGUMENTS+=(-ignore "Name laravel-api/vendor")
UNISON_ARGUMENTS+=(-ignore "Name laravel-api/storage")
UNISON_ARGUMENTS+=(-ignore "Name .oh-my-zsh") # This is entirely pulled from git
UNISON_ARGUMENTS+=(-ignore "Name .tmux")      # This is entirely pulled from git
UNISON_ARGUMENTS+=(-batch)                    # Causes it to propagate changes without stopping to ask first.

if [[ -d /mnt/c/Users/chris/Dropbox/BACKUPS/WSL2-Linux ]]; then
  cp /mnt/c/Users/*/AppData/Local/Packages/Microsoft.WindowsTerminal*/LocalState/settings.json /mnt/c/Users/chris/Dropbox/BACKUPS/WSL2-Linux/

  printf "\n${YELLOW}Backing up to Dropbox.${NC}\n"
  unison "${UNISON_ARGUMENTS[@]}"

fi
