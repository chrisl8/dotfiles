# https://askubuntu.com/questions/4014/how-do-i-renew-my-dhcp-lease
sudo dhclient -r
sudo dhclient > /dev/null 2>&1

