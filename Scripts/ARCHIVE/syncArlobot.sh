#unison /home/chrisl8/Dev/ArloBot/ArloBot ssh://arlobot//home/chrisl8/catkin_ws/src/ArloBot -ignore "Name {*.pyc}" -ignore "Path website/xscreenOld.png" -ignore "Path scripts/mjpg-streamer" -ignore "Path website/app/*.js" -ignore "Path website/app/*.js.map" -ignore "Path website/old-site/xscreen.png" -ignore "Path website/xscreen.png" -ignore "Path .git/index" -ignore "Path website/old-site/lcars/.git/index"
unison ${HOME} ssh://arlobot/${HOME} -path catkin_ws/src/ArloBot -ignore "Name {*.pyc}" -ignore "Name .git" -auto
unison ${HOME} ssh://arlobot/${HOME} -path .arlobot -auto
unison ${HOME}/ArloBotDev/opt/mycroft/ ssh://arlobot//opt/mycroft/ -ignore "Name {*.pyc}" -ignore "Name .git" -auto

