#!/bin/bash

echo "Running $0"

mkdir  -p --mode=0700 /root/.ssh && cat /custom/userkey.pub > /root/.ssh/authorized_keys 
[[ -d /home/tangarora ]] && (mkdir --mode=0700 /home/tangarora/.ssh && cat /custom/userkey.pub > /home/tangarora/.ssh/authorized_keys)


