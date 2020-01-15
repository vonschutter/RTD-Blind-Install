#!/bin/bash


wget -O /opt/rtd/scripts/post-install.sh "https://github.com/vonschutter/Blind_Install/raw/master/task.sh" --no-check-certificate 
mkdir  -p --mode=0700 /root/.ssh && cat /custom/userkey.pub > /root/.ssh/authorized_keys 
[[ -d /home/tangarora ]] && (mkdir --mode=0700 /home/tangarora/.ssh && cat /custom/userkey.pub > /home/tangarora/.ssh/authorized_keys)


