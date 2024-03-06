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

YELLOW='\033[1;33m'
BRIGHT_MAGENTA='\033[1;95m'
NC='\033[0m' # NoColor

printf "\n${YELLOW}Everything here is automatic, so you can walk away.${NC}\n"

DROPBOX_FOLDER=/mnt/d/Dropbox

DATA_ROOT_FOLDER=/mnt/d
export DATA_ROOT_FOLDER

"${SCRIPT_DIR}"/makeIndexableCopyOfObsidianMdFilesForDropbox.sh

if [[ -d ${DATA_ROOT_FOLDER}/Obsidian && -d ${DROPBOX_FOLDER}/Obsidian ]]; then
  printf "\n${BRIGHT_MAGENTA}Backing up Obsidian files to Dropbox${NC}\n"
  unison ${DATA_ROOT_FOLDER} ${DROPBOX_FOLDER} -path Obsidian -force ${DATA_ROOT_FOLDER} -auto -batch -ignore "Name .git"
fi

BACKUP_PATH="${DROPBOX_FOLDER}/BACKUPS/WSL2-Linux/home/chrisl8"

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
UNISON_ARGUMENTS+=(-batch) # Don't ask, just do it. This is a backup.

if [[ -d "${BACKUP_PATH}" ]]; then
  printf "\n${BRIGHT_MAGENTA}Backing up${YELLOW} ${HOME} ${BRIGHT_MAGENTA}to Dropbox.${NC}\n"
  unison "${UNISON_ARGUMENTS[@]}"
fi

ROOT_PATH="/mnt/c"
BACKUP_PATH="${DROPBOX_FOLDER}/BACKUPS/TheSilence/c"
FOLDER_TO_BACKUP="Dev"

UNISON_ARGUMENTS=()
UNISON_ARGUMENTS+=("${ROOT_PATH}")
UNISON_ARGUMENTS+=("${BACKUP_PATH}")
UNISON_ARGUMENTS+=(-force "${ROOT_PATH}")
UNISON_ARGUMENTS+=(-path "${FOLDER_TO_BACKUP}")
UNISON_ARGUMENTS+=(-perms 0)
UNISON_ARGUMENTS+=(-dontchmod)
UNISON_ARGUMENTS+=(-rsrc false)
UNISON_ARGUMENTS+=(-auto)
UNISON_ARGUMENTS+=(-links ignore)
UNISON_ARGUMENTS+=(-ignore "Name .unison*")
UNISON_ARGUMENTS+=(-ignore "Name .vscode-server")
UNISON_ARGUMENTS+=(-ignore "Name node_modules")
UNISON_ARGUMENTS+=(-ignore "Name .idea")
UNISON_ARGUMENTS+=(-ignore "Name .git") # If I exclude this, I lose git history for non-github repositories, but this is MOST of the churn, so doing it anyway.
UNISON_ARGUMENTS+=(-ignore "Name .godot") # Too much data nd churn here
UNISON_ARGUMENTS+=(-batch) # Don't ask, just do it. This is a backup.

if [[ -d "${ROOT_PATH}/${FOLDER_TO_BACKUP}" ]]; then
  printf "\n${BRIGHT_MAGENTA}Backing up${YELLOW} /mnt/c/Dev ${BRIGHT_MAGENTA}to Dropbox.${NC}\n"
  unison "${UNISON_ARGUMENTS[@]}"
fi

ROOT_PATH="/mnt/d"
BACKUP_PATH="${DROPBOX_FOLDER}/BACKUPS/TheSilence/d"
FOLDER_TO_BACKUP="Dev"

UNISON_ARGUMENTS=()
UNISON_ARGUMENTS+=("${ROOT_PATH}")
UNISON_ARGUMENTS+=("${BACKUP_PATH}")
UNISON_ARGUMENTS+=(-force "${ROOT_PATH}")
UNISON_ARGUMENTS+=(-path "${FOLDER_TO_BACKUP}")
UNISON_ARGUMENTS+=(-perms 0)
UNISON_ARGUMENTS+=(-dontchmod)
UNISON_ARGUMENTS+=(-rsrc false)
UNISON_ARGUMENTS+=(-auto)
UNISON_ARGUMENTS+=(-links ignore)
UNISON_ARGUMENTS+=(-ignore "Name .unison*")
UNISON_ARGUMENTS+=(-ignore "Name .vscode-server")
UNISON_ARGUMENTS+=(-ignore "Name node_modules")
UNISON_ARGUMENTS+=(-ignore "Name .idea")
UNISON_ARGUMENTS+=(-ignore "Name .git") # If I exclude this, I lose git history for non-github repositories, but this is MOST of the churn, so doing it anyway.
UNISON_ARGUMENTS+=(-batch) # Don't ask, just do it. This is a backup.

if [[ -d "${ROOT_PATH}/${FOLDER_TO_BACKUP}" ]]; then
  printf "\n${BRIGHT_MAGENTA}Backing up${YELLOW} /mnt/d/Dev ${BRIGHT_MAGENTA}to Dropbox.${NC}\n"
  unison "${UNISON_ARGUMENTS[@]}"
fi
