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

export NVM_DIR="${HOME}/.nvm"
export NVM_SYMLINK_CURRENT=true
# shellcheck source=/home/chrisl8/.nvm/nvm.sh
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh" # This loads nvm
NVM_TAG=$(curl -s curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep tag_name | cut -d '"' -f 4)
NVM_VERSION_LATEST="${NVM_TAG//v/}"
NVM_VERSION=$(nvm --version)
if [ "$NVM_VERSION" != "$NVM_VERSION_LATEST" ]; then
  printf "\n${BRIGHT_MAGENTA}Updating NVM from ${NVM_VERSION} to ${NVM_VERSION_LATEST}${NC}\n"

  if [[ -e ${HOME}/.nvm/nvm.sh ]]; then
    printf "${LIGHTBLUE}Deactivating existing Node Version Manager:${NC}\n"
    export NVM_DIR="${HOME}/.nvm"
    # shellcheck source=/home/chrisl8/.nvm/nvm.sh
    [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh" # This loads nvm
    nvm deactivate
  fi

  wget -qO- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_TAG/install.sh" | bash
  export NVM_DIR="${HOME}/.nvm"
  # shellcheck source=/home/chrisl8/.nvm/nvm.sh
  [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh" # This loads nvm

  export NVM_SYMLINK_CURRENT=true
  if ! (grep NVM_SYMLINK_CURRENT ~/.bashrc >/dev/null); then
    printf "\n${YELLOW}[Setting the NVM current environment in your .bashrc file]${NC}\n"
    sh -c "echo \"export NVM_SYMLINK_CURRENT=true\" >> ~/.bashrc"
  fi
  if ! (grep NVM_SYMLINK_CURRENT ~/.zshrc >/dev/null); then
    printf "\n${YELLOW}[Setting the NVM current environment in your .zshrc file]${NC}\n"
    sh -c "echo \"export NVM_SYMLINK_CURRENT=true\" >> ~/.zshrc"
  fi
fi

NODE_VERSION=$(node -v)

printf "\n${BRIGHT_MAGENTA}Node.js Updates${NC}\n"
nvm install node
nvm use node
nvm alias default node

NODE_VERSION_NEW=$(node -v)

NPM_VERSION=$(npm -v)
NPM_VERSION_LATEST=$(npm view npm version)
if [ "$NPM_VERSION" != "$NPM_VERSION_LATEST" ]; then
  printf "\n${BRIGHT_MAGENTA}Updating NPM from ${NPM_VERSION} to ${NPM_VERSION_LATEST}${NC}\n"
  npm i -g npm
fi

if [[ ${PM2_INSTALLED} == 1 ]]; then
  if [ "$NODE_VERSION" != "$NODE_VERSION_NEW" ] || [ "$(pm2 -v)" != "$(npm view pm2 version)" ];then
    printf "\n${BRIGHT_MAGENTA}Reinstalling/Updating PM2${NC}\n"
    npm i -g pm2
    pm2 install pm2-logrotate
    # I have literally never looked at a historical pm2 log, so retaining just 1 saves a lot of space on VMs and Raspberry Pis.
    pm2 set pm2-logrotate:retain 1
  fi
fi

printf "\n${BRIGHT_MAGENTA}Updating dotfiles Node dependencies${NC}\n"
# TODO: Only do this if dotfiles DID update or if Node.js was updated.
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

if [[ -e /etc/sudoers.d/"${USER}" ]]; then
  cp /etc/sudoers.d/"${USER}" "${SCRIPT_DIR}"/../sudoers.d/
fi

DROPBOX_FOLDER=/mnt/d/Dropbox

if [[ -d ${DROPBOX_FOLDER}/BACKUPS/WSL2-Linux ]]; then
  printf "\n${YELLOW}Remember to run backupToDropbox regularly too!${NC}\n"
fi

if (command -v wsl.exe); then
  if [[ $(hostname) = "KSCDTCL5864L-01" ]]; then
    printf "\n${YELLOW}Consider comparing your Windows Terminal version and updating it.${NC}\n"
  else
    printf "\n${YELLOW}You may want to update Chocolatey packages. Run Powershell as Admin and run:${NC}"
    printf "choco upgrade all -y"
  fi
fi

if [ "$NODE_VERSION" != "$NODE_VERSION_NEW" ]; then
  printf "\n${YELLOW}Node.js has been updated from ${NODE_VERSION} to ${NODE_VERSION_NEW}${NC}\n"
  printf "You should close this terminal session and start a new one to activate the new Node.js version.\n"
fi
