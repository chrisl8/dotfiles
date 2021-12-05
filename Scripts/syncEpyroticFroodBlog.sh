#!/bin/bash
REMOTE_IP=twoflower.ekpyroticfrood.net

UNISON_ARGUMENTS=()
UNISON_ARGUMENTS+=("${HOME}"/Dev)
UNISON_ARGUMENTS+=(ssh://"${REMOTE_IP}"//home/chrisl8/)
UNISON_ARGUMENTS+=(-path ekpyroticfrood-blog)
UNISON_ARGUMENTS+=(-auto)

unison "${UNISON_ARGUMENTS[@]}" # -batch
