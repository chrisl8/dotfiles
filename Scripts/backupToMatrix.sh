#!/bin/bash
# shellcheck disable=SC2059

set -e

# Grab and save the path to this script
# http://stackoverflow.com/a/246128
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
#echo "${SCRIPT_DIR}" # For debugging

export PATH=/home/chrisl8/dotfiles/bin:/home/chrisl8/bin:$PATH

YELLOW='\033[1;33m'
BRIGHT_MAGENTA='\033[1;95m'
NC='\033[0m' # NoColor

MATRIX_FOLDER=/mnt/e
BACKUP_FOLDER=${MATRIX_FOLDER}/Backups

DATA_ROOT_FOLDER=/mnt/d
export DATA_ROOT_FOLDER

"${SCRIPT_DIR}"/makeIndexableCopyOfObsidianMdFilesForDropbox.sh

BACKUP_PATH="${BACKUP_FOLDER}/WSL2-Linux/home/chrisl8"

UNISON_ARGUMENTS=()
UNISON_ARGUMENTS+=("${HOME}")
UNISON_ARGUMENTS+=("${BACKUP_PATH}")
UNISON_ARGUMENTS+=(-force "${HOME}")
UNISON_ARGUMENTS+=(-perms 0)
UNISON_ARGUMENTS+=(-dontchmod)
UNISON_ARGUMENTS+=(-rsrc false)
UNISON_ARGUMENTS+=(-auto)
UNISON_ARGUMENTS+=(-links ignore)
UNISON_ARGUMENTS+=(-ignore "Name Work/idat-cm-folder/dumper.py") # This file updates EVERY time, so excluding it
UNISON_ARGUMENTS+=(-ignore "Name Work/idat-cm-folder/Dumper.py") # This file updates EVERY time, so excluding it
UNISON_ARGUMENTS+=(-ignore "Name Work/NodeBinary")
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
UNISON_ARGUMENTS+=(-ignore "Name .parcel-cache")
UNISON_ARGUMENTS+=(-ignore "Name site-packages")
UNISON_ARGUMENTS+=(-ignore "Name .idea")
UNISON_ARGUMENTS+=(-ignore "Name laravel-api/vendor")
UNISON_ARGUMENTS+=(-ignore "Name laravel-api/storage")
UNISON_ARGUMENTS+=(-ignore "Name laravel-api/vendors")
UNISON_ARGUMENTS+=(-ignore "Name laravel-api/public/vendors")
UNISON_ARGUMENTS+=(-ignore "Name api/vendor")
UNISON_ARGUMENTS+=(-ignore "Name api/storage")
UNISON_ARGUMENTS+=(-ignore "Name api/vendors")
UNISON_ARGUMENTS+=(-ignore "Name api/public/vendors")
#UNISON_ARGUMENTS+=(-ignore "Name dotfiles/.git") # Already excluding .git
#UNISON_ARGUMENTS+=(-ignore "Name Dev/*/.git") # Already excluding .git
#UNISON_ARGUMENTS+=(-ignore "Name catkin_ws/*/.git") # Already excluding .git
UNISON_ARGUMENTS+=(-ignore "Name .oh-my-zsh") # This is entirely pulled from git
UNISON_ARGUMENTS+=(-ignore "Name .tmux")      # This is entirely pulled from git
UNISON_ARGUMENTS+=(-ignore "Name .opam")
UNISON_ARGUMENTS+=(-ignore "Name .gnupg")
UNISON_ARGUMENTS+=(-ignore "Name .zcompdump*")
UNISON_ARGUMENTS+=(-ignore "Name .cargo")
UNISON_ARGUMENTS+=(-ignore "Name .rustup")
UNISON_ARGUMENTS+=(-ignore "Name .pm2")
UNISON_ARGUMENTS+=(-ignore "Name .pm2-dev")
UNISON_ARGUMENTS+=(-ignore "Name .bash_history")
UNISON_ARGUMENTS+=(-ignore "Name .bash_logout")
UNISON_ARGUMENTS+=(-ignore "Name .config")
UNISON_ARGUMENTS+=(-ignore "Name .dbus")
UNISON_ARGUMENTS+=(-ignore "Name .java")
UNISON_ARGUMENTS+=(-ignore "Name .lesshst")
UNISON_ARGUMENTS+=(-ignore "Name .motd_shown")
UNISON_ARGUMENTS+=(-ignore "Name .mozilla")
UNISON_ARGUMENTS+=(-ignore "Name .node_repl_history")
UNISON_ARGUMENTS+=(-ignore "Name .pki")
UNISON_ARGUMENTS+=(-ignore "Name .pycharm_helpers")
UNISON_ARGUMENTS+=(-ignore "Name .python_history")
UNISON_ARGUMENTS+=(-ignore "Name .shell.pre-oh-my-zsh")
UNISON_ARGUMENTS+=(-ignore "Name .sudo_as_admin_successful")
UNISON_ARGUMENTS+=(-ignore "Name .vim")
UNISON_ARGUMENTS+=(-ignore "Name .viminfo")
UNISON_ARGUMENTS+=(-ignore "Name .wget-hsts")
UNISON_ARGUMENTS+=(-ignore "Name .git") # If I exclude this, I lose git history for non-github repositories, but this is MOST of the churn, so doing it anyway.
UNISON_ARGUMENTS+=(-ignore "Name .local/share/godot")
UNISON_ARGUMENTS+=(-ignore "Name Clone")
UNISON_ARGUMENTS+=(-ignore "Name hive-database-data") # The permissions on this folder will be broken due to running in Docker.
UNISON_ARGUMENTS+=(-ignore "Name .local/state")
UNISON_ARGUMENTS+=(-ignore "Name .local/share/JetBrains")
UNISON_ARGUMENTS+=(-ignore "Name .local/share/pnpm")
UNISON_ARGUMENTS+=(-ignore "Name .local/share/virtualenv")
UNISON_ARGUMENTS+=(-batch) # Don't ask, just do it. This is a backup.

if [[ -d "${BACKUP_FOLDER}" ]]; then
  mkdir -p "${BACKUP_FOLDER}/WSL2-Linux/home/chrisl8"
  printf "\n${BRIGHT_MAGENTA}Backing up${YELLOW} ${HOME} ${BRIGHT_MAGENTA}to Matrix.${NC}\n"
  unison "${UNISON_ARGUMENTS[@]}"
fi
