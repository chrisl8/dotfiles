#!/bin/bash
# shellcheck disable=SC2059

# https://docs.godotengine.org/en/stable/contributing/development/compiling/compiling_for_linuxbsd.html

set -e

YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
NC='\033[0m' # NoColor

# Kind of assuming if clang and lld exist, the rest do.
# TODO: Default is to use gcc now, so maybe move clang and lld check and install elsewhere?
if ! (command -v clang >/dev/null) || ! (command -v lld >/dev/null); then
  sudo apt install build-essential scons pkg-config libx11-dev libxcursor-dev libxinerama-dev libgl1-mesa-dev libglu-dev libasound2-dev libpulse-dev libudev-dev libxi-dev libxrandr-dev clang lld -y
fi

REPO_UPDATED="False"
USE_CLANG="False"

while test $# -gt 0
do
        case "$1" in
                --force) REPO_UPDATED="True"
                ;;
                --clang) USE_CLANG="True"
                ;;
        *) echo "Invalid argument"
                exit
                ;;
        esac
        shift
done

EMSDK_REPO_UPDATED="False"
EMSDK_QUIET=1
export EMSDK_QUIET
cd "${HOME}/Clone" || exit
if [[ -d "emsdk" ]]; then
  cd emsdk || exit
  git fetch
  LOCAL=$(git rev-parse @)
  REMOTE=$(git rev-parse "@{u}")
  if [[ "$LOCAL" != "$REMOTE" ]]; then
    EMSDK_REPO_UPDATED="True"
    printf "${LIGHTBLUE}Pulling updates for Emscripten SDK for Web Export Template build...${NC}\n"
    git pull
  fi
else
  EMSDK_REPO_UPDATED="True"
  printf "${LIGHTBLUE}Cloning Emscripten SDK for Web Export Template build...${NC}\n"
  gh repo clone emscripten-core/emsdk
  cd emsdk || exit
fi

if [[ $EMSDK_REPO_UPDATED == "True" ]]; then
  printf "${LIGHTBLUE}Updating Emscripten SDK for Web Export Template build...${NC}\n"
  ./emsdk install latest
fi
./emsdk activate latest > /dev/null
source ./emsdk_env.sh

printf "\n${YELLOW}Checking latest Godot version from GitHub.${NC}\n"
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

EDITOR_BINARY_NAME="godot.linuxbsd.editor.x86_64"
LINUX_EXPORT_TEMPLATE_NAME="godot.linuxbsd.template_release.x86_64"
if [[ $USE_CLANG == "True" ]]; then
  EDITOR_BINARY_NAME="godot.linuxbsd.editor.x86_64.llvm"
  LINUX_EXPORT_TEMPLATE_NAME="godot.linuxbsd.template_release.x86_64.llvm"
fi

if ! [[ -d bin ]] || ! [[ -e "bin/${EDITOR_BINARY_NAME}" ]] || ! [[ -e "bin/${LINUX_EXPORT_TEMPLATE_NAME}" ]] || [[ $REPO_UPDATED == "True" ]]; then
  if [[ $USE_CLANG == "True" ]]; then
    # Docs say using clang is faster, which is what use_llvm=yes does, but that GCC makes smaller faster binaries.
    # Docs say using LLD with clang is faster, which is what linker=lld does.
    printf "${LIGHTBLUE}  Building updated version of Godot with Clang...${NC}\n"
    scons -Q platform=linuxbsd production=yes use_llvm=yes linker=lld # module_text_server_adv_enabled=no module_text_server_fb_enabled=yes
    scons -Q platform=linuxbsd target=template_release production=yes use_llvm=yes linker=lld # module_text_server_adv_enabled=no module_text_server_fb_enabled=yes
  else
    printf "${LIGHTBLUE}  Building updated version of Godot with GCC...${NC}\n"
    scons -Q platform=linuxbsd production=yes # module_text_server_adv_enabled=no module_text_server_fb_enabled=yes
    scons -Q platform=linuxbsd target=template_release production=yes # module_text_server_adv_enabled=no module_text_server_fb_enabled=yes
  fi
  scons -Q platform=web target=template_release # module_text_server_adv_enabled=no module_text_server_fb_enabled=yes
  if [[ "$LOCAL" != "" ]] && [[ "$REMOTE" != "" ]]; then
    printf "${LIGHTBLUE}  Built godot with the following changes:${NC}\n"
    git --no-pager log --oneline ^"$LOCAL" "$REMOTE"
  fi
  printf "\n"
else
  printf "${LIGHTBLUE}No updates required.${NC}\n"
fi

EXPORT_TEMPLATE_FOLDER_NAME=$("bin/${EDITOR_BINARY_NAME}" --version | cut -d "." -f 1,2,3)
mkdir -p "$HOME/.local/share/godot/export_templates/${EXPORT_TEMPLATE_FOLDER_NAME}"
cp "bin/${LINUX_EXPORT_TEMPLATE_NAME}" "$HOME/.local/share/godot/export_templates/${EXPORT_TEMPLATE_FOLDER_NAME}/linux_debug.x86_64"
cp "bin/${LINUX_EXPORT_TEMPLATE_NAME}" "$HOME/.local/share/godot/export_templates/${EXPORT_TEMPLATE_FOLDER_NAME}/linux_release.x86_64"

printf "${YELLOW}Linux Export Template version $("$HOME/.local/share/godot/export_templates/${EXPORT_TEMPLATE_FOLDER_NAME}/linux_release.x86_64" --version) is built and in place.${NC}\n"

cp "bin/godot.web.template_release.wasm32.zip" "$HOME/.local/share/godot/export_templates/${EXPORT_TEMPLATE_FOLDER_NAME}/web_debug.zip"
cp "bin/godot.web.template_release.wasm32.zip" "$HOME/.local/share/godot/export_templates/${EXPORT_TEMPLATE_FOLDER_NAME}/web_release.zip"
printf "${YELLOW}Web Export Template was copied in place.${NC}\n"

if [[ -e /mnt/c/Users/chris/CLionProjects/godot/bin/godot.windows.template_release.x86_64.exe ]]; then
  cp "/mnt/c/Users/chris/CLionProjects/godot/bin/godot.windows.template_release.x86_64.exe" "$HOME/.local/share/godot/export_templates/${EXPORT_TEMPLATE_FOLDER_NAME}/windows_debug_x86_64.exe"
  cp "/mnt/c/Users/chris/CLionProjects/godot/bin/godot.windows.template_release.x86_64.exe" "$HOME/.local/share/godot/export_templates/${EXPORT_TEMPLATE_FOLDER_NAME}/windows_release_x86_64.exe"
  WINDOWS_EXPORT_TEMPLATE_VERSION=$("$HOME/.local/share/godot/export_templates/${EXPORT_TEMPLATE_FOLDER_NAME}/windows_release_x86_64.exe" --version)
  # https://stackoverflow.com/a/22045214/4982408
  printf "${YELLOW}Windows Export Template version $(tr -dc '[[:print:]]' <<< "$WINDOWS_EXPORT_TEMPLATE_VERSION") was copied in place.${NC}\n"
else
  printf "${YELLOW}Windows Export Template not found.${NC}\n"
fi

cp "bin/${EDITOR_BINARY_NAME}" "$HOME/bin"
cd "$HOME/bin"
if [[ -e godot ]]; then
  rm godot
fi
ln -s "${EDITOR_BINARY_NAME}" godot

printf "${YELLOW}Godot version $(godot --version) is built and in the path.${NC}\n"
