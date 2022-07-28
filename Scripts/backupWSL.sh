#!/bin/bash
# shellcheck disable=SC2059

set -e

# Grab and save the path to this script
# http://stackoverflow.com/a/246128
SOURCE="${BASH_SOURCE[0]}"
while [[ -L "$SOURCE" ]]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ ${SOURCE} != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
# echo "${SCRIPT_DIR}" # For debugging

UNISON_ARGUMENTS=()

UNISON_ARGUMENTS+=("${HOME}")
UNISON_ARGUMENTS+=(/mnt/d/Dropbox/BACKUPS/WSL2-Linux/home/chrisl8)
UNISON_ARGUMENTS+=(-force "${HOME}")
UNISON_ARGUMENTS+=(-perms 0)
UNISON_ARGUMENTS+=(-dontchmod)
UNISON_ARGUMENTS+=(-rsrc false)
UNISON_ARGUMENTS+=(-auto)
UNISON_ARGUMENTS+=(-links ignore)
UNISON_ARGUMENTS+=(-ignore "Name .vscode-server")
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
UNISON_ARGUMENTS+=(-ignore "Name .git") # If I exclude this, I lose git history for non-github repositories, but this is MOST of the churn, so doing it anyway.
UNISON_ARGUMENTS+=(-ignore "Name laravel-api/vendor")
UNISON_ARGUMENTS+=(-ignore "Name laravel-api/storage")
UNISON_ARGUMENTS+=(-ignore "Name laravel-api/vendors")
UNISON_ARGUMENTS+=(-ignore "Name laravel-api/public/vendors")
UNISON_ARGUMENTS+=(-ignore "Name dotfiles/.git")
UNISON_ARGUMENTS+=(-ignore "Name Dev/*/.git")
UNISON_ARGUMENTS+=(-ignore "Name catkin_ws/*/.git")
UNISON_ARGUMENTS+=(-ignore "Name .oh-my-zsh") # This is entirely pulled from git
UNISON_ARGUMENTS+=(-ignore "Name .tmux")      # This is entirely pulled from git
UNISON_ARGUMENTS+=(-ignore "Name .opam")
UNISON_ARGUMENTS+=(-ignore "Name .gnupg")
UNISON_ARGUMENTS+=(-ignore "Name .zcompdump*")
UNISON_ARGUMENTS+=(-batch)                    # Causes it to propagate changes without stopping to ask first.

if [[ -d /mnt/d/Dropbox/BACKUPS/WSL2-Linux ]]; then
  cp /mnt/c/Users/*/AppData/Local/Packages/Microsoft.WindowsTerminal_*/LocalState/settings.json /mnt/d/Dropbox/BACKUPS/WSL2-Linux/terminalSettings.json

  cp /mnt/c/Users/*/AppData/Local/Packages/Microsoft.WindowsTerminalPreview_*/LocalState/settings.json /mnt/d/Dropbox/BACKUPS/WSL2-Linux/terminalPreviewSettings.json

  printf "\n${YELLOW}Backing up to Dropbox.${NC}\n"
  unison "${UNISON_ARGUMENTS[@]}"

fi
