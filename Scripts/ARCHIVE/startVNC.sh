# This is to start X11 VNC, first install it with:
# sudo apt install x11vnc
# Then run this. It stops after you disconnect, but that is all I need.

echo "If you are using Remina, you MUST set up a saved connection and set Color depth to True Color (24 bit)"
x11vnc -display :0 -bg -reopen -forever

