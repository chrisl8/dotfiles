#http://stackoverflow.com/questions/9139417/how-to-scp-with-a-second-remote-host
#http://unix.stackexchange.com/questions/100859/ssh-tunnel-without-shell-on-ssh-server
# First, open the tunnel
ssh -f -N -L 3389:schrodinger:3389 -p 38920 root@home.lofland.net &
# Then, use the tunnel to copy the file directly from remote2
#scp -P 1234 user2@localhost:file .
echo "Use port 3389"

