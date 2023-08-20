#!/bin/bash
REMOTE_IP=voidshipephemeral.space
YELLOW='\033[1;33m'
NC='\033[0m' # NoColor

#printf "\n${YELLOW}Updating Signaling Server${NC}\n"
#cd /mnt/c/Dev/godot-test-project/signaling_server || exit
#scp server.js "${REMOTE_IP}":./godot_signaling_server
#scp package* "${REMOTE_IP}":./godot_signaling_server
#ssh "${REMOTE_IP}" 'cd ~/godot_signaling_server || exit && PATH=~/.nvm/current/bin:$PATH ~/.nvm/current/bin/npm ci --omit=dev'

printf "\n${YELLOW}Building${NC}\n"
cd /mnt/c/Dev/godot-test-project || exit
pwsh.exe -c "C:\Dev\GodotEngines\v4.1.1-stable_win64\Godot_v4.1.1-stable_win64_console.exe --headless --export-release --quiet 'Web'"
pwsh.exe -c "C:\Dev\GodotEngines\v4.1.1-stable_win64\Godot_v4.1.1-stable_win64_console.exe --headless --export-release --quiet 'Linux'"
# This isn't actually used anywhere, but I like having it built. In theory I could like slap a shortcut to it on my desktop, or upload it to Itch.io
pwsh.exe -c "C:\Dev\GodotEngines\v4.1.1-stable_win64\Godot_v4.1.1-stable_win64_console.exe --headless --export-release --quiet 'Win'"

printf "\n${YELLOW}Cache Busting${NC}\n"
TIMESTAMP=$(date +%s)
cd /mnt/c/Dev/godot_web_export || exit
rm test-*.*
# https://stackoverflow.com/a/7450854/4982408
for file in test.*
do
  mv "$file" "${file/test/test-$TIMESTAMP}"
done
mv test-${TIMESTAMP}.html test.html
sed -i -- "s/test/test-${TIMESTAMP}/g" test.html

printf "\n${YELLOW}Syncing Web Build${NC}\n"
UNISON_ARGUMENTS=()
UNISON_ARGUMENTS+=("/mnt/c/Dev")
UNISON_ARGUMENTS+=(ssh://"${REMOTE_IP}"//home/chrisl8/)
UNISON_ARGUMENTS+=(-force "/mnt/c/Dev")
UNISON_ARGUMENTS+=(-path godot_web_export)
UNISON_ARGUMENTS+=(-auto)
UNISON_ARGUMENTS+=(-batch)
unison "${UNISON_ARGUMENTS[@]}" # -batch

printf "\n${YELLOW}Syncing Linux Build${NC}\n"
UNISON_ARGUMENTS+=(-path godot_linux_export)
unison "${UNISON_ARGUMENTS[@]}" # -batch

printf "\n${YELLOW}Restarting Servers${NC}\n"
#ssh "${REMOTE_IP}" 'PATH=~/.nvm/current/bin:$PATH pm2 stop "Godot Server" && PATH=~/.nvm/current/bin:$PATH pm2 restart "Godot Signaling Server" && PATH=~/.nvm/current/bin:$PATH pm2 start "Godot Server"'
ssh "${REMOTE_IP}" 'PATH=~/.nvm/current/bin:$PATH pm2 restart "Godot Server"'
