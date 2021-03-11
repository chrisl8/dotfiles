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

#BLUE='\033[0;34m'
#GREEN='\033[0;32m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
#LIGHT_PURPLE='\033[1;35m'
YELLOW='\033[1;33m'
#LIGHTCYAN='\033[1;36m'
#LIGHTBLUE='\033[1;34m'
#LIGHTPURPLE='\033[1;35m'
NC='\033[0m' # NoColor

cd "${SCRIPT_DIR}"

git pull

LOGOUT=false

if ! (command -v zsh >/dev/null) || ! (command -v tmux >/dev/null) || ! (command -v keychain >/dev/null) || ! (command -v wget >/dev/null); then
  sudo apt install -y zsh tmux keychain wget
fi

if [[ -d /mnt/c/Users/chris/Dropbox ]] && ! [[ -L "${HOME}/Dropbox" ]]; then
  cd || exit
  ln -s /mnt/c/Users/chris/Dropbox .
  echo yes
fi

if ! [[ -d "${HOME}"/.ssh ]]; then
  cd || exit
  mkdir .ssh
  chmod go-rwx .ssh
  printf "\n${RED}Add your SSH keys to ~/.ssh !!!${NC}\n"
fi

cd || exit
if ! [[ -d .tmux ]]; then
  printf "\n${PURPLE}Installing Oh My TMUX!${NC}\n"
  git clone https://github.com/gpakosz/.tmux.git
fi
if [[ -f .tmux.conf ]]; then
  rm .tmux.conf
fi
if ! [[ -L .tmux.conf ]]; then
  ln -s .tmux/.tmux.conf .
fi

if [[ -f .tmux.conf.local ]]; then
  rm .tmux.conf.local
fi
if ! [[ -L .tmux.conf.local ]]; then
  ln -s dotfiles/.tmux.conf.local .
fi

cd || exit
if ! [[ -d "${HOME}"/.oh-my-zsh ]]; then
  LOGOUT=true
  printf "\n${PURPLE}Installing Oh My ZSH!${NC}\n"
  printf "\n${YELLOW}After this is done, it leaves you at a prompt,${NC}\n"
  printf "\n${YELLOW}type exit to leave that ZSH prompt and finish this setup!${NC}\n"
  sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
fi

if [[ -d "${HOME}"/.oh-my-zsh ]] && ! [[ -d "${HOME}"/.oh-my-zsh/custom/themes/powerlevel10k ]]; then
  LOGOUT=true
  printf "\n${PURPLE}Installing Powerlevel10k${NC}\n"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${HOME}"/.oh-my-zsh/custom/themes/powerlevel10k
fi

cd || exit
if [[ -f .zshrc ]]; then
  rm .zshrc
fi
if ! [[ -L .zshrc ]]; then
  ln -s dotfiles/.zshrc .
fi

cd || exit
if [[ -f .zshenv ]]; then
  rm .zshenv
fi
if ! [[ -L .zshenv ]]; then
  ln -s dotfiles/.zshenv .
fi

if ! (grep "${USER}" /etc/passwd | grep zsh >/dev/null); then
  LOGOUT=true
  printf "\n${PURPLE}Setting ZSH as your default shell.${NC}\n"
  # Actually I think Oh My ZSH does this itself anyway, but it doesnt' hurt.
  chsh -s "$(which zsh)"
fi

if [[ "${LOGOUT}" == "true" ]]; then
  printf "\n${RED}Your should probably reboot, or at least log out and back in for settings to take effect...${NC}\n"
  printf "\n${YELLOW}Don't forget to set up your Terminal fonts!${NC}\n"
  printf "\n${YELLOW}See README.md for instructions.${NC}\n"
fi

cd || exit

# TODO: Set up .zshenv to use pi32 or pi64 bin folders for Pi
