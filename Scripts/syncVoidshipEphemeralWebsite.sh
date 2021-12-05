#!/bin/bash
REMOTE_IP=twoflower.ekpyroticfrood.net

UNISON_ARGUMENTS=()
UNISON_ARGUMENTS+=("${HOME}"/Dev/voidship-ephemeral-website)
UNISON_ARGUMENTS+=(ssh://"${REMOTE_IP}"//home/chrisl8/voidship-ephemeral-website)
UNISON_ARGUMENTS+=(-path out)
UNISON_ARGUMENTS+=(-auto)

unison "${UNISON_ARGUMENTS[@]}" # -batch
