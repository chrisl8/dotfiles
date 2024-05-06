#!/bin/bash
# shellcheck disable=SC2059

set -e

# Colors: https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit
#BLUE='\033[0;34m'
#GREEN='\033[0;32m'
RED='\033[0;31m'
#PURPLE='\033[0;35m'
#LIGHT_PURPLE='\033[1;35m'
YELLOW='\033[1;33m'
LIGHT_CYAN='\033[1;36m'
#LIGHT_BLUE='\033[1;34m'
#LIGHT_PURPLE='\033[1;35m'
#BRIGHT_WHITE='\033[1;97m'
BRIGHT_MAGENTA='\033[1;95m'
NC='\033[0m' # NoColor

cd "${SCRIPT_DIR}"

PACKAGE_MANAGER=""

declare -A osInfo;
osInfo[/etc/redhat-release]=yum
osInfo[/etc/arch-release]=pacman
osInfo[/etc/gentoo-release]=emerge
osInfo[/etc/SuSE-release]=zypp
osInfo[/etc/debian_version]=apt
osInfo[/etc/alpine-release]=apk

for f in "${!osInfo[@]}"
do
    if [[ -f $f ]];then
        PACKAGE_MANAGER=${osInfo[$f]}
    fi
done

if [[ "${PACKAGE_MANAGER}" == "apt" ]]; then
  printf "\n${LIGHT_CYAN}[Install APT packages]${NC}\n"
  sudo apt update
  sudo apt install -y zsh tmux keychain wget curl vim
fi

if (command -v sw_vers >/dev/null); then
  printf "\n${LIGHT_CYAN}[Install Homebrew packages]${NC}\n"
  if ! (command -v brew >/dev/null); then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  brew install python gh scons node
elif ! (command -v gh >/dev/null); then
  # https://github.com/cli/cli/blob/trunk/docs/install_linux.md
  printf "\n${YELLOW}[Installing Github CLI]${NC}\n"
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
  sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt update
  sudo apt install gh -y
  printf "\n${YELLOW}You will probably need to run 'gh auth login' once and then run this setup script again.${NC}\n"
  printf "\nUse 'BROWSER=false gh auth login' to force display of a URL instead of opening a browser.${NC}\n"
fi

cd || exit 1
if ! [[ -d ~/dotfiles ]]; then
  gh repo clone chrisl8/dotfiles
fi

cd ~/dotfiles || exit 1
git pull

LOGOUT=false

if [[ -d /mnt/c/Users/chris/Dropbox ]] && ! [[ -L "${HOME}/Dropbox" ]]; then
  cd || exit 1
  ln -s /mnt/c/Users/chris/Dropbox .
  echo yes
fi

if [[ -d /mnt/d/Dropbox ]] && ! [[ -L "${HOME}/Dropbox" ]]; then
  cd || exit 1
  ln -s /mnt/d/Dropbox .
  echo yes
fi

if ! [[ -d "${HOME}"/.ssh ]]; then
  cd || exit 1
  mkdir .ssh
  chmod go-rwx .ssh
  printf "\n${RED}Add your SSH keys to ~/.ssh !!!${NC}\n"
fi

cd || exit 1
if ! [[ -d .tmux ]]; then
  printf "\n${BRIGHT_MAGENTA}Installing Oh My TMUX!${NC}\n"
  gh repo clone https://github.com/gpakosz/.tmux.git
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

cd || exit 1
if ! [[ -d "${HOME}"/.oh-my-zsh ]]; then
  LOGOUT=true
  printf "\n${BRIGHT_MAGENTA}Installing Oh My ZSH!${NC}\n"
  printf "\n${YELLOW}After this is done, it MAY leave you at a strange empty ~ prompt.${NC}\n"
  printf "\n${YELLOW}If so, type exit to leave that ZSH prompt and finish this setup!${NC}\n"
  sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
fi

if [[ -d "${HOME}"/.oh-my-zsh ]] && ! [[ -d "${HOME}"/.oh-my-zsh/custom/themes/powerlevel10k ]]; then
  LOGOUT=true
  printf "\n${BRIGHT_MAGENTA}Installing Powerlevel10k${NC}\n"
  gh repo clone https://github.com/romkatv/powerlevel10k.git "${HOME}"/.oh-my-zsh/custom/themes/powerlevel10k -- --depth=1
fi

cd || exit 1
if [[ -f .zshrc ]]; then
  rm .zshrc
fi
if ! [[ -L .zshrc ]]; then
  ln -s dotfiles/.zshrc .
fi

cd || exit 1
if [[ -f .zshenv ]]; then
  rm .zshenv
fi
if ! [[ -L .zshenv ]]; then
  ln -s dotfiles/.zshenv .
fi

cd || exit 1
if [[ -f .p10k.zsh ]]; then
  rm .p10k.zsh
fi
if ! [[ -L .p10k.zsh ]]; then
  ln -s dotfiles/.p10k.zsh .
fi

if ! (command -v sw_vers >/dev/null) && ! (grep "${USER}" /etc/passwd | grep zsh >/dev/null); then
  LOGOUT=true
  printf "\n${BRIGHT_MAGENTA}Setting ZSH as your default shell.${NC}\n"
  # Actually I think Oh My ZSH does this itself anyway, but it doesnt' hurt.
  sudo chsh -s "$(which zsh)" "$(whoami)"
fi

if [[ "${LOGOUT}" == "true" ]]; then
  printf "\n${RED}Your should probably reboot, or at least log out and back in for settings to take effect...${NC}\n"
  printf "\n${YELLOW}Don't forget to set up your Terminal fonts!${NC}\n"
  printf "\n${YELLOW}See README.md for instructions.${NC}\n"
fi

cd || exit 1

cd || exit 1
if [[ -f .vimrc ]]; then
  rm .vimrc
fi
if ! [[ -L .vimrc ]]; then
  ln -s dotfiles/.vimrc .
fi

cd || exit 1
if [[ -e .local ]] && [[ -e .local/share ]]; then
  if ! [[ -e .local/share/fonts ]]; then
    cd ~/.local/share
    ln -s ~/dotfiles/fonts .
    cd || exit 1
  fi
fi

printf "\n${BRIGHT_MAGENTA}VIM Setup${NC}\n"
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

cd || exit 1

  if ! (command -v brew >/dev/null); then
  printf "\n${BRIGHT_MAGENTA}Node.js via nvm${NC}\n"
  printf "\n${LIGHT_CYAN}[Installing/Updating Node Version Manager]${NC}\n"
  if ! [[ -e ${HOME}/.nvm/nvm.sh ]]; then
    NVM_TAG=$(curl -s curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep tag_name | cut -d '"' -f 4)
    wget -qO- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_TAG/install.sh" | bash
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

  nvm install node --latest-npm
  nvm use node
  nvm alias default node
fi


cd ~/dotfiles/node || exit 1
npm ci
cd || exit 1

printf "\n${BRIGHT_MAGENTA}GIT Settings${NC}\n"
git config --global user.name "Christen Lofland"
git config --global user.email "christen@lofland.net"
git config --global init.defaultBranch main
git config --global core.autocrlf false

printf "\n${YELLOW}NOTE: This script installs, but may or may not update things.${NC}\n"
printf "\n${LIGHT_CYAN}You can run this again and again, in case there is something new to install,${NC}\n"
printf "\n${LIGHT_CYAN}but consider running updateAllTheThings.sh to update things too!${NC}\n"
