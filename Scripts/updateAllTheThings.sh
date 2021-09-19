#!/usr/bin/env zsh
# shellcheck disable=SC2059

#BLUE='\033[0;34m'
#GREEN='\033[0;32m'
#RED='\033[0;31m'
PURPLE='\033[0;35m'
#LIGHT_PURPLE='\033[1;35m'
YELLOW='\033[1;33m'
#LIGHTCYAN='\033[1;36m'
#LIGHTBLUE='\033[1;34m'
#LIGHTPURPLE='\033[1;35m'
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

printf "\n${PURPLE}Updating dotfiles${NC}\n"
cd ~/dotfiles || exit
git pull
cd || exit

printf "\n${PURPLE}Updating Oh My ZSH!${NC}\n"
env ZSH="$ZSH" sh "$ZSH"/tools/upgrade.sh

printf "\n${PURPLE}Updating powerlevel10k${NC}\n"
git -C "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k pull

printf "\n${PURPLE}Updating Oh My TMUX!${NC}\n"
cd ~/.tmux || exit
git pull
cd || exit

printf "\n${PURPLE}VIM Updates${NC}\n"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim -c ':PlugClean | quit | quit'
vim -c ':PlugUpdate | quit | quit'

printf "\n${PURPLE}Ubuntu Updates${NC}\n"
sudo apt update
sudo apt -y upgrade
sudo apt -y autoremove

printf "\n${PURPLE}Node.js Updates${NC}\n"
export NVM_DIR="${HOME}/.nvm"
export NVM_SYMLINK_CURRENT=true
# shellcheck source=/home/chrisl8/.nvm/nvm.sh
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh" # This loads nvm
nvm install --lts

"${SCRIPT_DIR}"/makeIndexableCopyOfObsidianMdFilesForDropbox.sh

QUICKEN_FOLDER_ROOT=/mnt/c/Users/chris/Documents
if [[ -d ${QUICKEN_FOLDER_ROOT}/Quicken && -d /home/chrisl8/Dropbox/Quicken ]]; then
  printf "\n${PURPLE}Backing up Quicken files to Dropbox${NC}\n"
  unison ${QUICKEN_FOLDER_ROOT} /home/chrisl8/Dropbox -path Quicken -force ${QUICKEN_FOLDER_ROOT} -auto -batch
fi

if [[ -d /mnt/c/Users/chris/Dropbox/BACKUPS/WSL2-Linux ]]; then
  printf "\n${YELLOW}Consider running backupWSL too!${NC}\n"
fi

if [[ $(hostname) = "KSCDTCL5864L-01" ]]; then
  printf "\n${YELLOW}Consider comparing your Windows Terminal version and updating it.${NC}\n"
fi
