#!/usr/bin/env zsh
# shellcheck disable=SC2059

#BLUE='\033[0;34m'
#GREEN='\033[0;32m'
#RED='\033[0;31m'
#PURPLE='\033[0;35m'
#LIGHT_PURPLE='\033[1;35m'
YELLOW='\033[1;33m'
#LIGHTCYAN='\033[1;36m'
#LIGHTBLUE='\033[1;34m'
#LIGHTPURPLE='\033[1;35m'
BRIGHT_MAGENTA='\033[1;95m'
NC='\033[0m' # NoColor

set -e

# Grab and save the path to this script
# http://stackoverflow.com/a/246128
# https://stackoverflow.com/questions/9901210/bash-source0-equivalent-in-zsh
SOURCE="${(%):-%x}"
while [[ -L "$SOURCE" ]]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ ${SOURCE} != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
# echo "${SCRIPT_DIR}" # For debugging

printf "\n${BRIGHT_MAGENTA}Updating dotfiles${NC}\n"
cd ~/dotfiles || exit
git pull
cd || exit

printf "\n${BRIGHT_MAGENTA}Updating Oh My ZSH!${NC}\n"
env ZSH="$ZSH" zsh "$ZSH"/tools/upgrade.sh

printf "\n${BRIGHT_MAGENTA}Updating powerlevel10k${NC}\n"
git -C "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k pull

printf "\n${BRIGHT_MAGENTA}Updating Oh My TMUX!${NC}\n"
cd ~/.tmux || exit
git pull
cd || exit

printf "\n${BRIGHT_MAGENTA}VIM Updates${NC}\n"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim -c ':PlugClean | quit | quit'
vim -c ':PlugUpdate | quit | quit'

printf "\n${BRIGHT_MAGENTA}Ubuntu Updates${NC}\n"
sudo apt update
sudo apt -y upgrade
sudo apt -y autoremove

PM2_INSTALLED=0
if (command -v pm2 >/dev/null); then
  PM2_INSTALLED=1
fi

printf "\n${BRIGHT_MAGENTA}Node.js Updates${NC}\n"
export NVM_DIR="${HOME}/.nvm"
export NVM_SYMLINK_CURRENT=true
# shellcheck source=/home/chrisl8/.nvm/nvm.sh
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh" # This loads nvm

nvm install node
nvm use node
nvm alias default node

printf "\n${BRIGHT_MAGENTA}Installing latest NPM version${NC}\n"
npm i -g npm

if [[ ${PM2_INSTALLED} == 1 ]]; then
  printf "\n${BRIGHT_MAGENTA}Reinstalling PM2${NC}\n"
  npm i -g pm2
  pm2 install pm2-logrotate
  # I have literally never looked at a historical pm2 log, so retaining just 1 saves a lot of space on VMs and Raspberry Pis.
  pm2 set pm2-logrotate:retain 1
fi

cd "${SCRIPT_DIR}/../node"
npm ci
cd "${SCRIPT_DIR}"

if (command -v wsl.exe); then
  # https://github.com/microsoft/WSL/issues/8603#issuecomment-1357669697
  printf "\n${BRIGHT_MAGENTA}WSL Updates${NC}\n"
  printf "NOTE: If this just terminates Linux or otherwise fails, you may need to open PowerShell AS ADMINISTRATOR and run:\n"
  printf "wsl --update\n"
  printf "or if that fails try:\n"
  printf "wsl --update --web-download\n\n"
  wsl.exe --update || true
  wsl.exe --status
fi

DROPBOX_FOLDER=/mnt/d/Dropbox

DATA_ROOT_FOLDER=/mnt/d
export DATA_ROOT_FOLDER
if [[ -d ${DATA_ROOT_FOLDER}/Quicken && -d ${DROPBOX_FOLDER}/Quicken ]]; then
  printf "\n${BRIGHT_MAGENTA}Backing up Quicken files to Dropbox${NC}\n"
  unison ${DATA_ROOT_FOLDER} ${DROPBOX_FOLDER} -path Quicken -force ${DATA_ROOT_FOLDER} -auto -batch
fi

"${SCRIPT_DIR}"/makeIndexableCopyOfObsidianMdFilesForDropbox.sh

if [[ -d ${DATA_ROOT_FOLDER}/Obsidian && -d ${DROPBOX_FOLDER}/Obsidian ]]; then
  printf "\n${BRIGHT_MAGENTA}Backing up Obsidian files to Dropbox${NC}\n"
  unison ${DATA_ROOT_FOLDER} ${DROPBOX_FOLDER} -path Obsidian -force ${DATA_ROOT_FOLDER} -auto -batch -ignore "Name .git"
fi

printf "\n${YELLOW}Does the current version of nvm we installed:${NC} "
nvm --version
printf "${YELLOW}Match the version on github:${NC} "
curl -s https://api.github.com/repositories/612230/releases/latest | grep tag_name | cut -d '"' -f 4

curl -s https://api.github.com/repos/612230/latest

if [[ -e /etc/sudoers.d/"${USER}" ]]; then
  cp /etc/sudoers.d/"${USER}" "${SCRIPT_DIR}"/../sudoers.d/
fi

if [[ -d ${DROPBOX_FOLDER}/BACKUPS/WSL2-Linux ]]; then
  printf "\n${YELLOW}Consider running backupWSL too!${NC}\n"
fi

if [[ $(hostname) = "KSCDTCL5864L-01" ]]; then
  printf "\n${YELLOW}Consider comparing your Windows Terminal version and updating it.${NC}\n"
fi
