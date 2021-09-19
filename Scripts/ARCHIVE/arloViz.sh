export ROS_MASTER_URI=http://twoflower:11311
export ROS_HOSTNAME=`uname -n`
export ROSLAUNCH_SSH_UNKNOWN=1
source ~/catkin_ws/devel/setup.bash
${HOME}/catkin_ws/src/ArloBot/scripts/view-navigation.sh
