#!/bin/bash

# Run this automatically by making a file called
# ~/.config/autostart/chrisl8.desktop
# with these contents:
#[Desktop Entry]
#Type=Application
#Version=1.0
#Name=Chris L8 Startup Stuff
#Comment=Autostart
#Terminal=false
#Exec=/home/chrisl8/Dropbox/allLinux/Scripts/runAtUnlock.sh

${HOME}/Dropbox/allLinux/Scripts/fixKeyboardShortcuts.sh

# See https://askubuntu.com/questions/974199/how-to-run-a-script-at-screen-lock-unlocks-in-ubuntu-17-10/1045429#1045429

# Note, some versions of Gnome and/or Desktop setups use LockedHint
#dbus-monitor --session "type='signal',interface='org.gnome.LockedHint'" | \
# but PopOS is using ScreenSaver
dbus-monitor --session "type='signal',interface='org.gnome.ScreenSaver'" | \
( while true
    do read X
    if echo $X | grep "boolean true" &> /dev/null; then
        echo "locking at $(date)" >> ${HOME}/screen-lock.log
    elif echo $X | grep "boolean false" &> /dev/null; then
        echo "unlocking at $(date)" >> ${HOME}/screen-lock.log
        ${HOME}/Dropbox/allLinux/Scripts/fixKeyboardShortcuts.sh
    fi
    done )
