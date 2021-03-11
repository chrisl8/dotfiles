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
NC='\033[0m' # NoColor

set -e

# Grab and save the path to this script
# http://stackoverflow.com/a/246128
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

env ZSH="$ZSH" sh "$ZSH"/tools/upgrade.sh

printf "\n${PURPLE}Updating powerlevel10k${NC}\n"
git -C "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/themes/powerlevel10k pull

printf "\n${PURPLE}Updating Oh My TMUX!${NC}\n"
cd ~/.tmux || exit
git pull
cd || exit

printf "\n${PURPLE}Ubuntu Updates${NC}\n"
sudo apt update
sudo apt -y upgrade
sudo apt -y autoremove

if [[ -d /mnt/c/Users/chris/Dropbox/BACKUPS/WSL2-Linux ]]; then
  printf "\n${YELLOW}Consider running backupWSL too!${NC}\n"
fi
