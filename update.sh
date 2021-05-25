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

BLUE='\033[0;34m'
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

sudo apt install -y zsh tmux keychain wget curl vim

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
  printf "\n${YELLOW}After this is done, it MAY leave you at a strange empty ~ prompt.${NC}\n"
  printf "\n${YELLOW}If so, type exit to leave that ZSH prompt and finish this setup!${NC}\n"
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

cd || exit
if [[ -f .p10k.zsh ]]; then
  rm .p10k.zsh
fi
if ! [[ -L .p10k.zsh ]]; then
  ln -s dotfiles/.p10k.zsh .
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

cd || exit
if [[ -f .vimrc ]]; then
  rm .vimrc
fi
if ! [[ -L .vimrc ]]; then
  ln -s dotfiles/.vimrc .
fi

cd || exit
if ! [[ -e .local/share/fonts ]]; then
  cd ~/.local/share
  ln -s ~/dotfiles/fonts .
  cd || exit
fi

printf "\n${PURPLE}VIM Setup${NC}\n"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

if ! [[ -d .vim/plugged ]]; then
  mkdir -p ~/.vim/plugged
fi

if ! [[ -d .vim/plugged/darcula ]]; then
  printf "\n${YELLOW}Ignore the error about missing color schemes and press Enter.${NC}\n"
fi

vim -c ':PlugInstall | quit | quit'
vim -c ':PlugClean | quit | quit'
vim -c ':PlugUpdate | quit | quit'

cd || exit

printf "\n${PURPLE}GIT Settings${NC}\n"
git config --global core.autocrlf input

printf "\n${PURPLE}Node.js via nvm${NC}\n"
# Copied from arlobot's setup-noetic.sh
printf "${BLUE}[Installing/Updating Node Version Manager]${NC}\n"
if ! [[ -e ${HOME}/.nvm/nvm.sh ]]; then
  wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
fi

export NVM_DIR="${HOME}/.nvm"
export NVM_SYMLINK_CURRENT=true
# shellcheck source=/home/chrisl8/.nvm/nvm.sh
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh" # This loads nvm

if ! (grep NVM_SYMLINK_CURRENT ~/.bashrc >/dev/null); then
  printf "\n${YELLOW}[Setting the NVM current environment in your .bashrc file]${NC}\n"
  sh -c "echo \"export NVM_SYMLINK_CURRENT=true\" >> ~/.bashrc"
  # NOTE: This is already set it our standard .zshrc file, so no need to set it there.
fi

nvm install --lts

printf "\n${YELLOW}NOTE: This script installs, but may or may not update things.${NC}\n"
printf "\n${BLUE}You can run this again and again, in case there is something new to install,${NC}\n"
printf "\n${BLUE}but consider running updateAllTheTHings.sh to update things too!${NC}\n"

# TODO: Set up .zshenv to use pi32 or pi64 bin folders for Pi
