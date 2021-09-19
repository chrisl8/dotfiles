#!/bin/bash
IP=192.168.1.45
echo Prework Backup:
ssh ${IP} /home/chrisl8/Work/Scripts/backupWork.sh
ssh ${IP} /home/chrisl8//Dropbox/allLinux/Scripts/backupDev.sh
echo allLinux:
unison ${HOME} ssh://${IP}/${HOME} -path Dropbox/allLinux -auto -ignore "Name .uuid"
echo ATT:
unison ${HOME} ssh://${IP}/${HOME} -path att -follow "Path att" -auto -perms=0
echo Work Pre-Pass:
unison ${HOME} ssh://${IP}/${HOME} -path Work -auto -times -ignore "Name laravel-api/storage"
if [ ${?} -eq 0 ]; then
  echo Work Watcher:
  unison ${HOME} ssh://${IP}/${HOME} -path Work -auto -batch -times -ignore "Name laravel-api/storage" -ignore "Name node_modules" -repeat watch
else
  echo $?
fi
echo allLinux:
unison ${HOME} ssh://${IP}/${HOME} -path Dropbox/allLinux -auto -ignore "Name .uuid"
echo ATT:
unison ${HOME} ssh://${IP}/${HOME} -path att -follow "Path att" -auto -perms=0
echo End of day backup:
ssh ${IP} /home/chrisl8/Work/Scripts/backupWork.sh
ssh ${IP} /home/chrisl8//Dropbox/allLinux/Scripts/backupDev.sh
