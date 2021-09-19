#!/bin/bash
unison ${HOME}/Dev ${HOME}/Dropbox/DevBackup -perms 0 -rsrc false -auto -links false -ignore "Name node_modules" -batch
unison ${HOME}/ArlobotDev ${HOME}/Dropbox/ArlobotDevBackup -perms 0 -rsrc false -auto -links false -ignore "Name node_modules" -batch
unison ${HOME}/UnityGames ${HOME}/Dropbox/UnityGames -perms 0 -rsrc false -auto -links false -batch
