#!/bin/bash
# shellcheck disable=SC2059

# https://docs.godotengine.org/en/stable/contributing/development/compiling/compiling_for_linuxbsd.html

set -e

YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
NC='\033[0m' # NoColor

printf "\n${YELLOW}Checking latest Godot version from GitHub.${NC}\n"

# Kind of assuming if clang and lld exist, the rest do.
if ! (command -v clang >/dev/null) || ! (command -v lld >/dev/null); then
  sudo apt install build-essential scons pkg-config libx11-dev libxcursor-dev libxinerama-dev libgl1-mesa-dev libglu-dev libasound2-dev libpulse-dev libudev-dev libxi-dev libxrandr-dev clang lld -y
fi

REPO_UPDATED="False"

while test $# -gt 0
do
        case "$1" in
                --force) REPO_UPDATED="True"
                ;;
        *) echo "Invalid argument"
                exit
                ;;
        esac
        shift
done

LOCAL=""
REMOTE=""
cd "${HOME}/Clone" || exit
if [[ -d "godot" ]]; then
  cd godot || exit
  git fetch
  LOCAL=$(git rev-parse @)
  REMOTE=$(git rev-parse "@{u}")
  if [[ "$LOCAL" != "$REMOTE" ]]; then
    REPO_UPDATED="True"
    printf "${LIGHTBLUE}Pulling updates for Godot...${NC}\n"
    git pull
  fi
else
  REPO_UPDATED="True"
  gh repo clone godotengine/godot
  cd godot || exit
fi

if ! [[ -d bin ]] || ! [[ -e bin/godot.linuxbsd.editor.x86_64.llvm ]] || [[ $REPO_UPDATED == "True" ]]; then
  # Docs say using clang is faster, which is what use_llvm=yes does.
  # Docs say using LLD is faster, which is what linker=lld does.
  printf "${LIGHTBLUE}  Building updated version of Godot...${NC}\n"
  scons -Q platform=linuxbsd use_llvm=yes linker=lld production=yes
  printf "${LIGHTBLUE}  Built godot with the following changes:${NC}\n"
  git --no-pager log --oneline ^"$LOCAL" "$REMOTE"
  printf "\n"
else
  printf "${LIGHTBLUE}No updates required.${NC}\n"
fi

cp bin/godot.linuxbsd.editor.x86_64.llvm "$HOME/bin"
cd "$HOME/bin"
if [[ -e godot ]]; then
  rm godot
fi
ln -s godot.linuxbsd.editor.x86_64.llvm godot

printf "${YELLOW}Godot version $(godot --version) is built and in the path.${NC}\n"
