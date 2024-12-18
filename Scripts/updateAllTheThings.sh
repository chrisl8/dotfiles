#!/usr/bin/env zsh
# shellcheck disable=SC2059

#BLUE='\033[0;34m'
#GREEN='\033[0;32m'
#RED='\033[0;31m'
#PURPLE='\033[0;35m'
#LIGHT_PURPLE='\033[1;35m'
YELLOW='\033[1;33m'
#LIGHTCYAN='\033[1;36m'
LIGHTBLUE='\033[1;34m'
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

if [[ -d ~/Scripts/.git ]]; then
  printf "\n${BRIGHT_MAGENTA}Updating Scripts${NC}\n"
  cd ~/Scripts || exit
  git pull
  cd || exit
fi

if [[ -d ~/Orac/.git ]]; then
  printf "\n${BRIGHT_MAGENTA}Updating Orac${NC}\n"
  cd ~/Orac || exit
  git pull
  cd ~/Orac/node || exit
  npm i
  cd || exit
fi

if (command -v zsh >/dev/null); then
  printf "\n${BRIGHT_MAGENTA}Updating Oh My ZSH!${NC}\n"
  if [[ ${ZSH} == "" ]]; then
    ZSH=~/.oh-my-zsh
  fi
  env ZSH="$ZSH" zsh "$ZSH"/tools/upgrade.sh
fi

printf "\n${BRIGHT_MAGENTA}Updating powerlevel10k${NC}\n"
git -C "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k pull

printf "\n${BRIGHT_MAGENTA}Updating Oh My TMUX!${NC}\n"
cd ~/.tmux || exit
git pull
cd || exit

printf "\n${BRIGHT_MAGENTA}VIM Updates${NC}\n"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim || true
vim -c ':PlugClean | quit | quit'
vim -c ':PlugUpdate | quit | quit'

if [[ -e /etc/debian_version ]]; then
  printf "\n${BRIGHT_MAGENTA}Ubuntu Updates${NC}\n"
  sudo apt update
  sudo apt -y upgrade
  sudo apt -y autoremove
fi

if (command -v brew >/dev/null); then
  brew update
  brew upgrade
fi

if (command -v pamac >/dev/null); then
  printf "\n${BRIGHT_MAGENTA}Manjaro Updates${NC}\n"
  pamac update
fi

# NOTE: Only update things that YOU installed via pip.
# It often breaks things to use pip to install system level packages, as they were probably installed
# by Ubuntu itself.
if ! (command -v pamac >/dev/null) && (command -v pip >/dev/null); then
  printf "\n${BRIGHT_MAGENTA}Python Updates${NC}\n"
  printf "\n${LIGHTBLUE}Updating PIP${NC}\n"
  set +e
  sudo /usr/bin/python -m pip install --upgrade pip
  set -e
  #printf "\n${LIGHTBLUE}Install/Updating Python Packages${NC}\n"
fi

PM2_INSTALLED=0
if (command -v pm2 >/dev/null); then
  PM2_INSTALLED=1
fi

export NVM_DIR="${HOME}/.nvm"
if [[ -e "${NVM_DIR}/nvm.sh" ]]; then
  # shellcheck source=/home/chrisl8/.nvm/nvm.sh
  [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh" # This loads nvm
fi

if (command -v nvm); then
  export NVM_SYMLINK_CURRENT=true
  # shellcheck source=/home/chrisl8/.nvm/nvm.sh
  [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh" # This loads nvm
  NVM_TAG=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep tag_name | cut -d '"' -f 4)
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
  nvm install --lts
  nvm use --lts
  nvm alias default "lts/*"

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
fi

if [[ -e "${SCRIPT_DIR}/../../dotfiles/node/package.json" ]]; then
  printf "\n${BRIGHT_MAGENTA}Updating dotfiles Node dependencies${NC}\n"
  # TODO: Only do this if dotfiles DID update or if Node.js was updated.
  cd "${SCRIPT_DIR}/../../dotfiles/node"
  npm i
  cd "${SCRIPT_DIR}"
fi

if [[ -n "$WSL_DISTRO_NAME" ]]; then
  # https://github.com/microsoft/WSL/issues/8603#issuecomment-1357669697
  printf "\n${BRIGHT_MAGENTA}WSL Updates${NC}\n"
  printf "NOTE: If this just terminates Linux or otherwise fails, you may need to open PowerShell AS ADMINISTRATOR and run:\n"
  printf "wsl.exe --update\n"
  printf "or if that fails try:\n"
  printf "wsl.exe --update --web-download\n\n"
  wsl.exe --update || true
  wsl.exe --status
  wsl.exe --version
fi

if [[ -e /etc/sudoers.d/"${USER}" ]]; then
  cp /etc/sudoers.d/"${USER}" "${SCRIPT_DIR}"/../sudoers.d/
fi

if [ "$NODE_VERSION" != "$NODE_VERSION_NEW" ]; then
  printf "\n${YELLOW}Node.js has been updated from ${NODE_VERSION} to ${NODE_VERSION_NEW}${NC}\n"
  printf "You should close this terminal session and start a new one to activate the new Node.js version.\n"
fi
