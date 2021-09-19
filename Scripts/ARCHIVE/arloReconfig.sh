export ROS_MASTER_URI=http://arlobot:11311
export ROS_HOSTNAME=`uname -n`
export ROSLAUNCH_SSH_UNKNOWN=1
source ~/catkin_ws/devel/setup.bash
rosrun rqt_reconfigure rqt_reconfigure

