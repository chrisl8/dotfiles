#!/bin/bash
# shellcheck disable=SC2059

# Using --fast-web command line argument will skip all steps not strictly required for a new web deploy.
# This can speed up testing.
RAPID_DEPLOY=false

while test $# -gt 0
do
        case "$1" in
                --fast-web) RAPID_DEPLOY=true
                ;;
        *) echo "Invalid argument"
                exit
                ;;
        esac
        shift
done

GAME_NAME=space-game
PM2_TITLE="Space Game"
REMOTE_IP=voidshipephemeral.space
PROJECT_PATH=/mnt/c/Dev/space-game
OUTPUT_PATH=${HOME}/${GAME_NAME}

YELLOW='\033[1;33m'
NC='\033[0m' # NoColor

# NOTES:
# This script assumes that you have put the Godot engine somewhere in the path and linked it to the name godot
# cd ~/bin
# wget https://github.com/godotengine/godot/releases/download/4.1.1-stable/Godot_v4.1.1-stable_linux.x86_64.zip
# unzip Godot_v4.1.1-stable_linux.x86_64.zip
# chmod +x Godot_v4.1.1-stable_linux.x86_64
# ln -s Godot_v4.1.1-stable_linux.x86_64 godot

# And that you have downloaded the export templates
# cd ~/.local/share/godot/export_templates
# wget https://github.com/godotengine/godot/releases/download/4.1.1-stable/Godot_v4.1.1-stable_export_templates.tpz
# unzip Godot_v4.1.1-stable_export_templates.tpz
# mv templates 4.1.1.stable

printf "\n${YELLOW}Installing Required Dependencies${NC}\n"
type -p zip >/dev/null || (sudo apt update && sudo apt install zip -y)

printf "\n${YELLOW}Building Godot Release Bundles${NC}"
rm -rf "${OUTPUT_PATH}"
printf "\n\t${YELLOW}Web${NC}\n"
mkdir -p "${OUTPUT_PATH}/web"
godot --headless --quiet --path "${PROJECT_PATH}" --export-release 'Web' "${OUTPUT_PATH}/web/${GAME_NAME}.html"
printf "\n\t${YELLOW}Linux${NC}\n"
mkdir -p "${OUTPUT_PATH}/linux"
godot  --headless --quiet --path "${PROJECT_PATH}" --export-release 'Linux' "${OUTPUT_PATH}/linux/${GAME_NAME}.x86_64"
if [[ "${RAPID_DEPLOY}" == "false" ]]; then
  printf "\n\t${YELLOW}Windows${NC}\n"
  # This isn't actually used anywhere, but I like having it built. In theory I could like slap a shortcut to it on my desktop, or upload it to Itch.io
  mkdir -p "${OUTPUT_PATH}/windows"
  godot  --headless --quiet --path "${PROJECT_PATH}" --export-release 'Win' "${OUTPUT_PATH}/windows/${GAME_NAME}.exe"
fi

printf "\n${YELLOW}Cache Busting${NC}\n"
# Most web servers and browsers are really bad about caching too aggressively when it comes to binary files
# This both ensures updated files do not cache,
# and allows for highly aggressive caching to be used to save bandwidth for you and your users.
cd "${OUTPUT_PATH}/web" || exit
# The .png file is not used by default
# See: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html
rm "${GAME_NAME}.png"
# The game index file can use the default web server index name,
# as it is never internally referenced.
# See: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html
mv "${GAME_NAME}.html" index.html
# Use my own icons
cp "${PROJECT_PATH}/export-helpers/web/icons/favicon-128x128.png" "${GAME_NAME}.icon.png"
cp "${PROJECT_PATH}/export-helpers/web/icons/favicon-180x180.png" "${GAME_NAME}.apple-touch-icon.png"
# Godot generates some javascript to overwrite the icon which isn't documented,
# so I'm just commenting it out for now.
# There is probably a way to leverage it instead of thwart it.
sed -i -- "s/GodotDisplay.window_icon =/\/\/GodotDisplay.window_icon =/g" "${GAME_NAME}.js"
# Some other files must use the same name as the .wasm file, so we cache that
WASM_FILE_CHECK_SUM=$(sha224sum "${GAME_NAME}.wasm" | awk '{ print $1 }')

# https://stackoverflow.com/a/7450854/4982408
for file in "${GAME_NAME}".*
do
  if ! [[ ${file} == index.html ]];then
    if [[ ${file} == ${GAME_NAME}.wasm ]] || [[ ${file} == ${GAME_NAME}.worker.js ]] || [[ ${file} == ${GAME_NAME}.audio.worklet.js ]];then
      # Based on experimentation the .worker.js file MUST use the same name as the .wasm file.
      # I have no idea what the .audio.worklet.js does, but added it here just in case.
      #     As far as I can tell, my deploy never uses .audio.worklet.js
      # Including .wasm here just to save the time of calculating it twice.
      CHECK_SUM=${WASM_FILE_CHECK_SUM}
    else
      CHECK_SUM=$(sha224sum "${file}" | awk '{ print $1 }')
    fi
    NEW_FILE_NAME=${file/${GAME_NAME}/${GAME_NAME}-${CHECK_SUM}}
    mv "$file" "${NEW_FILE_NAME}"
    sed -i -- "s/${file}/${NEW_FILE_NAME}/g" index.html

    if [[ ${file} == "${GAME_NAME}.wasm" ]];then
      # The "executable" is the name of the .wasm file with-OUT the extension
      # See https://docs.godotengine.org/en/stable/tutorials/platform/web/html5_shell_classref.html#EngineConfig
      sed -i -- "s/\"executable\":\"${GAME_NAME}\"/\"executable\":\"${GAME_NAME}-${CHECK_SUM}\"/g" index.html
    fi

    if [[ ${file} == "${GAME_NAME}.pck" ]];then
      # The "mainPack" is the name of the .pck file WITH the extension,
      # as it could be .pck or possibly .zip
      # See https://docs.godotengine.org/en/stable/tutorials/platform/web/html5_shell_classref.html#EngineConfig
      # Without this, the engine uses the same name for the .pck file as the .wasm file,
      # which would prevent us from using a different checksum on the .pck file from the .wasm file,
      # and the .wasm file is both the largest file and the file that changes the least,
      # so we really want to use a distinct checksum on the .pck and .wasm files.
      sed -i -- "s/\"executable\":/\"mainPack\":\"${NEW_FILE_NAME}\",\"executable\":/g" index.html
    fi

  fi
done

if [[ "${RAPID_DEPLOY}" == "false" ]]; then
  printf "\n${YELLOW}Packaging Binary Release Files${NC}"
  mkdir -p "${OUTPUT_PATH}/web/release"

  printf "\n\t${YELLOW}Linux${NC}\n"
  cd "${OUTPUT_PATH}/linux" || exit
  tar -cvf Space-Game-Linux-Binary.tar ./*
  gzip -9 Space-Game-Linux-Binary.tar
  mv Space-Game-Linux-Binary.tar.gz "${OUTPUT_PATH}/web/release"

  printf "\n\t${YELLOW}Windows${NC}\n"
  cd "${OUTPUT_PATH}/windows" || exit
  zip -9 Space-Game-Windows-Binary.zip ./*
  mv Space-Game-Windows-Binary.zip "${OUTPUT_PATH}/web/release"
fi

printf "\n${YELLOW}Syncing Builds to Server${NC}"
printf "\n\t${YELLOW}Syncing Web Content${NC}\n"
UNISON_ARGUMENTS=()
UNISON_ARGUMENTS+=("${OUTPUT_PATH}")
UNISON_ARGUMENTS+=("ssh://${REMOTE_IP}//home/chrisl8/${GAME_NAME}")
UNISON_ARGUMENTS+=(-force "${OUTPUT_PATH}")
UNISON_ARGUMENTS+=(-path web)
UNISON_ARGUMENTS+=(-auto)
UNISON_ARGUMENTS+=(-batch)
unison "${UNISON_ARGUMENTS[@]}" # -batch

printf "\n\t${YELLOW}Syncing Linux Binary (for Server)${NC}\n"
# Copy in the run script for the Linux server
cp "${PROJECT_PATH}/export-helpers/server/run-server.sh" "${OUTPUT_PATH}/linux"

UNISON_ARGUMENTS+=(-path linux)
unison "${UNISON_ARGUMENTS[@]}" # -batch

printf "\n${YELLOW}Restarting Server${NC}\n"
ssh "${REMOTE_IP}" "PATH=~/.nvm/current/bin:\$PATH pm2 restart \"${PM2_TITLE}\""

if [[ "${RAPID_DEPLOY}" == "false" ]]; then
  ONEDRIVE_PATH=/mnt/c/Users/chris/OneDrive/Pandorica/SpaceGame
  if [[ -d ${ONEDRIVE_PATH} ]];then
    printf "\n${YELLOW}Syncing Onedrive Copy${NC}\n"
    UNISON_ARGUMENTS=()
    UNISON_ARGUMENTS+=("${OUTPUT_PATH}/windows")
    UNISON_ARGUMENTS+=("${ONEDRIVE_PATH}")
    UNISON_ARGUMENTS+=(-force "${OUTPUT_PATH}/windows")
    UNISON_ARGUMENTS+=(-perms 0)
    UNISON_ARGUMENTS+=(-dontchmod)
    UNISON_ARGUMENTS+=(-rsrc false)
    UNISON_ARGUMENTS+=(-links ignore)
    UNISON_ARGUMENTS+=(-auto)
    UNISON_ARGUMENTS+=(-batch)
    unison "${UNISON_ARGUMENTS[@]}" # -batch
  fi
fi