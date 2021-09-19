#!/bin/bash
# You will need to copy unison and unison-fsmonitor to the remote and put themin ~/bin/
# and add this line to the top of .bashrc
#export PATH=${HOME}/bin:${PATH}
TWOFLOWER=192.168.1.29
#unison ${HOME} ssh://${TWOFLOWER}/${HOME} -path Dropbox/allLinux -auto -ignore "Name .uuid"

#unison ${HOME} ssh://${TWOFLOWER}/${HOME} -path .arlobot -auto
unison ${HOME} ssh://${TWOFLOWER}/${HOME} -force ${HOME} -path catkin_ws/src/ArloBot -ignore "Name {*.pyc}" -ignore "Name xscreen.png" -ignore "Name xscreenOld.png" -ignore "Name node_modules" -ignore "Name arlobot_backup_recovery" -ignore "Name mycroft-core" -ignore "Name turtlebot" -auto
if [ ${?} -eq 0 ]; then
    unison ${HOME} ssh://${TWOFLOWER}/${HOME} -force ${HOME} -path catkin_ws/src/ArloBot -ignore "Name {*.pyc}" -ignore "Name xscreen.png" -ignore "Name xscreenOld.png" -ignore "Name node_modules" -ignore "Name arlobot_backup_recovery" -ignore "Name mycroft-core" -ignore "Name turtlebot" -auto -batch -repeat watch
fi
#unison ${HOME} ssh://${TWOFLOWER}/${HOME} -path .arlobot -auto
