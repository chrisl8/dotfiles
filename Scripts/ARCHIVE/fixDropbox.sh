# !/bin/bash
# Use this just in case the dropbox panel icon doesn't work
echo turning off dropbox to restart with panel icon &&
dropbox stop && sleep 30s &&
echo restarting starting dropbox with the panel icon &&
sleep 1s && dbus-launch dropbox start

