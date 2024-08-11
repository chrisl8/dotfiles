#!/bin/bash

export NVM_DIR="${HOME}/.nvm"
if [[ -e "${NVM_DIR}/nvm.sh" ]]; then
  # shellcheck source=/home/chrisl8/.nvm/nvm.sh
  [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh" # This loads nvm
fi
nvm use node

source "${HOME}/OCR/.venv/bin/activate"

cd "${HOME}/dotfiles/node" || exit
node processPdfs.js /mnt/e/ScanHere
