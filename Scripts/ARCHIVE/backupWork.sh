#!/bin/bash
unison ${HOME}/Work ${HOME}/Dropbox/DevWorkBackup -perms 0 -rsrc false -auto -links false -batch -force ${HOME}/Work -ignore "Name DeploymentToolsForCL5864/bin/node*" -ignore "Name DatabaseBackups" -ignore "Name node_modules"
