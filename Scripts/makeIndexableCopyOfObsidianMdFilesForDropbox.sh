#!/bin/bash
# shellcheck disable=SC2059

# OneDrive will not index .md files,
# even though it understands them quite well.
# This creates a folder full of copies of all of the .md files as .txt
# so that they show up in OneDrive searches, and then I can know to
# go open the file in the actual Obsidian folder.

BRIGHT_MAGENTA='\033[1;95m'
NC='\033[0m' # NoColor

OBSIDIAN_FOLDER="${DATA_ROOT_FOLDER}"/Obsidian
MARKDOWN_FOLDER="${OBSIDIAN_FOLDER}"/The\ Library\ of\ Babel
TEXT_INDEX_FOLDER="${OBSIDIAN_FOLDER}"/Obsidian\ Text\ Index\ for\ OneDrive

if [[ -d "${MARKDOWN_FOLDER}" && -d "${TEXT_INDEX_FOLDER}" ]]; then
  printf "\n${BRIGHT_MAGENTA}Updating .txt copies of Obsidian files for OneDrive${NC}\n"
  cd "${MARKDOWN_FOLDER}" || exit

  CHANGES_FOUND=0

  # https://stackoverflow.com/a/9612232/4982408
  shopt -s globstar
  for i in **/*.md; do # Whitespace-safe and recursive
    TEXT_FILE_NAME="${i/.md/.txt}"
    INDEX_FILE_PATH="${TEXT_INDEX_FOLDER}/$(basename "${TEXT_FILE_NAME}")"
    LOCAL_CHANGES_FOUND=0

    if ! [[ -e "${INDEX_FILE_PATH}" ]]; then
      LOCAL_CHANGES_FOUND=1
    else
      if [[ $(diff "${i}" "${INDEX_FILE_PATH}") ]]; then
        LOCAL_CHANGES_FOUND=1
      fi
    fi

    if [[ "${LOCAL_CHANGES_FOUND}" == "1" ]]; then
      CHANGES_FOUND=1
      echo "${i}"
      cp "${i}" "${INDEX_FILE_PATH}"
    fi
  done

  # Clean up .txt files left after .md file deletion
  cd "${TEXT_INDEX_FOLDER}" || exit
  # https://stackoverflow.com/a/9612232/4982408
  shopt -s globstar
  for i in **/*.txt; do # Whitespace-safe and recursive
    MD_FILE_NAME="${i/.txt/.md}"
    cd "${MARKDOWN_FOLDER}" || exit
    if (($(find . -name "${MD_FILE_NAME}" | wc -l) == 0)); then
      CHANGES_FOUND=1
      echo "${i}"
      cd "${TEXT_INDEX_FOLDER}" || exit
      rm "${i}"
    fi
  done
fi
