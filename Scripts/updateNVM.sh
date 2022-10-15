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

wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
export NVM_DIR="${HOME}/.nvm"
# shellcheck source=/home/chrisl8/.nvm/nvm.sh
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh" # This loads nvm

export NVM_SYMLINK_CURRENT=true
if ! (grep NVM_SYMLINK_CURRENT ~/.bashrc >/dev/null); then
  printf "\n${YELLOW}[Setting the NVM current environment in your .bashrc file]${NC}\n"
  sh -c "echo \"export NVM_SYMLINK_CURRENT=true\" >> ~/.bashrc"
fi
nvm install --lts
nvm alias default "lts/*"

printf "\n${YELLOW}Does the current version of nvm we installed:${NC} "
nvm --version
printf "${YELLOW}Match the version on github:${NC} "
wget -qO- https://github.com/creationix/nvm/blob/master/README.md | grep install.sh | grep wget | sed -e "s/<pre><code>//" | sed "s/\//\\n/g" | grep ^v | head -1
