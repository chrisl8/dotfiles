#!/bin/bash

printf "\n${YELLOW}[Installing and Initializing the Current Node LTS version]${NC}\n"

printf "${LIGHTBLUE}[Installing/Updating Node Version Manager]${NC}\n"
if [[ -e ${HOME}/.nvm/nvm.sh ]]; then
  printf "${LIGHTBLUE}Deactivating existing Node Version Manager:${NC}\n"
  export NVM_DIR="${HOME}/.nvm"
  # shellcheck source=/home/chrisl8/.nvm/nvm.sh
  [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh" # This loads nvm
  nvm deactivate
fi

NVM_VERSION=$(curl -s https://api.github.com/repositories/612230/releases/latest | grep tag_name | cut -d '"' -f 4)

wget -qO- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash
export NVM_DIR="${HOME}/.nvm"
# shellcheck source=/home/chrisl8/.nvm/nvm.sh
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh" # This loads nvm

export NVM_SYMLINK_CURRENT=true
if ! (grep NVM_SYMLINK_CURRENT ~/.bashrc >/dev/null); then
  printf "\n${YELLOW}[Setting the NVM current environment in your .bashrc file]${NC}\n"
  sh -c "echo \"export NVM_SYMLINK_CURRENT=true\" >> ~/.bashrc"
fi

printf "\n${YELLOW}Does the current version of nvm we installed:${NC} "
nvm --version
printf "${YELLOW}Match the version on github:${NC} "
curl -s https://api.github.com/repositories/612230/releases/latest | grep tag_name | cut -d '"' -f 4
