#!/bin/bash
# shellcheck disable=SC2059

# Dropbox will not index .md files,
# even though it understands them quite well.
# This creates a folder full of copies of all of the .md files as .txt
# so that they show up in Dropbox searches, and then I can know to
# go open the file in the actual Obsidian folder.

PURPLE='\033[0;35m'
NC='\033[0m' # NoColor

OBSIDIAN_FOLDER="${HOME}"/Dropbox/Obsidian/
MARKDOWN_FOLDER="${OBSIDIAN_FOLDER}"The\ Library\ of\ Babel/
TEXT_INDEX_FOLDER="${OBSIDIAN_FOLDER}"Obsidian\ Text\ Index\ for\ Dropbox

if [[ -d "${MARKDOWN_FOLDER}" && -d "${TEXT_INDEX_FOLDER}" ]]; then
  printf "\n${PURPLE}Updating .txt copies of Obsidian files for Dropbox${NC}\n"
  cd "${MARKDOWN_FOLDER}" || exit
  # First copy the .md files to the folder.
  # https://stackoverflow.com/a/15617049/4982408
  find . -name '*.md' -print0 | xargs -0 cp -t "${TEXT_INDEX_FOLDER}"
  # Pause to let Dropbox/Windows deal with reality
  sleep 1
  # Then rename them to .txt
  # TODO: In a perfect world this should walk the files, compare checksums,
  # and only update files if they changed, so that Dropbox doesn't get
  # all of these spurious updates.
  cd "${TEXT_INDEX_FOLDER}" || exit
  rm ./*.txt
  # https://stackoverflow.com/a/44965562/4982408
  # NOTE: File names have SPACES!
  find . -name '*.md' -exec bash -c 'mv "$0" "${0/md/txt}"' {} \;

  printf "\n${PURPLE}Committing Obsidian note changes to git${NC}\n"
  cd "${OBSIDIAN_FOLDER}" || exit
  git add -A && git commit -m "$(date)"
fi
