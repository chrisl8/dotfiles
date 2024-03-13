#!/bin/bash
# shellcheck disable=SC2059

# https://docs.godotengine.org/en/stable/contributing/development/compiling/compiling_for_linuxbsd.html

set -e

YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
NC='\033[0m' # NoColor

while test $# -gt 0; do
  COMMIT=$1
  shift
done

if [[ "${COMMIT}" == "" ]]; then
  printf "\n${YELLOW}No commit provided. Exiting script.${NC}\n"
  exit
fi

ROOT_FOLDER_PATH="${HOME}/Clone/godot-custom-builds/"
FOLDER_PATH="${ROOT_FOLDER_PATH}${COMMIT}"

if ! [[ -d "${FOLDER_PATH}" ]]; then
  printf "\n${YELLOW}Building Godot at Commit ${COMMIT}${NC}\n"
  gh repo sync chrisl8/godot
  cd "${HOME}/Clone/godot" || exit
  git fetch
  git checkout "${COMMIT}"
  scons -Q platform=linuxbsd use_llvm=yes linker=lld production=yes
  mkdir -p "${FOLDER_PATH}"
  cp -r bin "${FOLDER_PATH}"
fi

printf "${YELLOW}Godot version $("${ROOT_FOLDER_PATH}/godot.linuxbsd.editor.x86_64.llvm" --version --version) is built and in the path.${NC}\n"
