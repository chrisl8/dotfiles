#http://stackoverflow.com/questions/9139417/how-to-scp-with-a-second-remote-host
#http://unix.stackexchange.com/questions/100859/ssh-tunnel-without-shell-on-ssh-server
# First, open the tunnel
ssh -f -N -L 1234:ubuntu:22 -p 38920 root@home.lofland.net &
# Then, use the tunnel to copy the file directly from remote2
#scp -P 1234 user2@localhost:file .
echo "Use port 1234"
echo "ie. scp -P 1234 localhost:<filename> ."

