#!/bin/bash
# shellcheck disable=SC2059

set -e

YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
NC='\033[0m' # NoColor


if ! (command -v dotnet >/dev/null); then
  printf "\n${YELLOW}Installing Required Dependencies${NC}\n"
  type -p dotnet >/dev/null || (sudo apt update && sudo apt install dotnet-sdk-8.0 -y)
fi

printf "\n${YELLOW}Pulling down latest Godot build artifacts${NC}\n"
printf "${LIGHTBLUE}Note that these might not always exist${NC}\n"

function downloadArtifact() {
  ARTIFACT_ID=$(curl -sJL "$GET_ARTIFACT_ID_PATH" | grep location | cut -d "=" -f 2 | cut -d "<" -f 1 | cut -d "/" -f 9 | tr -d '"')

  if [[ -e "godot_${ARTIFACT_PLATFORM}_current_artifact_id.txt" ]]; then
    CURRENT_ARTIFACT_ID=$(cat "godot_${ARTIFACT_PLATFORM}_current_artifact_id.txt")
    if [[ "$ARTIFACT_ID" == "$CURRENT_ARTIFACT_ID" ]]; then
      printf "\n${LIGHTBLUE}Latest $ARTIFACT_PLATFORM $ARTIFACT_TYPE already downloaded.${NC}\n"
      return
    fi
  fi
  echo "$ARTIFACT_ID" > "godot_${ARTIFACT_PLATFORM}_current_artifact_id.txt"

  printf "\n${LIGHTBLUE}Downloading $ARTIFACT_PLATFORM $ARTIFACT_TYPE...${NC}\n"

  curl -sL -H "Authorization: Bearer $(op.exe read "op://Private/Github Readonly Token/password")" "https://api.github.com/repos/godotengine/godot/actions/artifacts/$ARTIFACT_ID/zip" --output artifact.zip

  if [[ -e artifact.zip ]] && file artifact.zip | grep -q "Zip archive"; then
    printf "\n${LIGHTBLUE}$ARTIFACT_PLATFORM $ARTIFACT_TYPE $(godot --version) downloaded.${NC}\n"
  else
    printf "\n${YELLOW}$ARTIFACT_PLATFORM $ARTIFACT_TYPE failed to download.${NC}\n"
    if [[ -e artifact.zip ]]; then
      rm artifact.zip
    fi
    return
  fi
}

# Linux Editor
ARTIFACT_PLATFORM="Linux"
ARTIFACT_TYPE="Editor"
GET_ARTIFACT_ID_PATH="https://godotengine.github.io/godot-commit-artifacts/download/godotengine/godot/master/linux-editor-mono"
cd "${HOME}/bin" || exit
downloadArtifact
if [[ -e artifact.zip ]]; then
  if [[ -e godot.linuxbsd.editor.x86_64.mono ]]; then
    rm godot.linuxbsd.editor.x86_64.mono
  fi
  if [[ -d GodotSharp ]]; then
    rm -rf GodotSharp
  fi
  unzip -qq artifact.zip
  chmod +x godot.linuxbsd.editor.x86_64.mono
  if [[ -e godot ]]; then
    rm godot
  fi
  ln -s godot.linuxbsd.editor.x86_64.mono godot
  rm artifact.zip
fi


# Export Templates
VERSION="4.3.dev.mono"
ALTERNATE_VERSION="4.3.dev"
ARTIFACT_TYPE="Export Template"

if ! [[ -d ${HOME}/.local/share/godot/export_templates/$VERSION ]]; then
  mkdir -p "${HOME}/.local/share/godot/export_templates/$VERSION"
fi
cd "${HOME}/.local/share/godot/export_templates" || exit
if ! [[ -e $ALTERNATE_VERSION ]]; then
  ln -s $VERSION $ALTERNATE_VERSION
fi
cd "${HOME}/.local/share/godot/export_templates/$VERSION" || exit

# Linux Export Templates
GET_ARTIFACT_ID_PATH="https://godotengine.github.io/godot-commit-artifacts/download/godotengine/godot/master/linux-template-mono"
downloadArtifact
if [[ -e artifact.zip ]]; then
  if [[ -e godot.linuxbsd.template_release.x86_64.mono ]]; then
    rm godot.linuxbsd.template_release.x86_64.mono
  fi
  if [[ -e linux_debug.x86_64 ]]; then
    rm linux_debug.x86_64
  fi
  if [[ -e linux_release.x86_64 ]]; then
    rm linux_release.x86_64
  fi
  unzip -qq artifact.zip
  cp godot.linuxbsd.template_release.x86_64.mono linux_debug.x86_64
  mv godot.linuxbsd.template_release.x86_64.mono linux_release.x86_64
  rm artifact.zip
fi

# Windows Export Templates
ARTIFACT_PLATFORM="Windows"
GET_ARTIFACT_ID_PATH="https://godotengine.github.io/godot-commit-artifacts/download/godotengine/godot/master/windows-template"
downloadArtifact
if [[ -e artifact.zip ]]; then
  unzip -qq -o artifact.zip
  cp godot.windows.template_release.x86_64.exe windows_release_x86_64.exe
  mv godot.windows.template_release.x86_64.exe windows_debug_x86_64.exe
  rm artifact.zip
fi

# Web Export Templates
ARTIFACT_PLATFORM="Web"
GET_ARTIFACT_ID_PATH="https://godotengine.github.io/godot-commit-artifacts/download/godotengine/godot/master/web-template"
downloadArtifact
if [[ -e artifact.zip ]]; then
  unzip -qq -o artifact.zip
  cp godot.web.template_release.wasm32.zip web_release.zip
  mv godot.web.template_release.wasm32.zip web_debug.zip
  rm artifact.zip
fi
