#!/bin/bash
echo				-	RTD System System Managment Bootstrap Script      -
#::
#::
#:: 						Shell Script Section
#::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#:: Author(s):   	SLS, KLS, NB.  Buffalo Center, IA & Avarua, Cook Islands
#:: Version:	1.06
#::
#::
#:: Purpose: 	The purpose of the script is to decide what scripts to download based
#::          	on the host OS found; works with both Windows, MAC and Linux systems.
#::		The focus of this script is to be compatible enough that it could be run on any
#::		system and compete it's job. In this case it is simply to identify the OS
#::		and get the appropriate script files to run on the system in question;
#::		In its original configuration this bootstrap script was used to install and
#::		configure software appropriate for the system in question. It accomplishes this
#::		by using the idiosyncrasies of the default scripting languages found in
#::		the most popular operating systems around *NIX (MAC, Linux, BSD etc.) 
#::
#::
#:: Background: This system configuration and installation script was originally developed
#:: 		for RuntimeData, a small OEM in Buffalo Center, IA. The purpose of the script
#:: 		was to install and/or configure Ubuntu, Zorin, or Microsoft OS PC's. This OEM and store nolonger
#:: 		exists as its owner has passed away. This script is shared in the hopes that
#:: 		someone will find it usefull.
#::
#::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#	
#		
# 
#	RTD admin scrips are placed in /opt/rtd/scripts. Optionally scripts may use the common
#	functions in _rtd_functions and _rtd_recipies. 
#	  _rtd_functions -- contain usefull admin functions for scripts, such as "how to install software" on different systems. 
#	  _rtd_recipies  -- contain software installation and configuration "recipies". 
#	Scripts may also be stand-alone if there is a reason for this. 



#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#::::::::::::::                                          ::::::::::::::::::::::
#::::::::::::::          Script Settings                 ::::::::::::::::::::::
#::::::::::::::                                          ::::::::::::::::::::::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Variables that govern the behavior or the script and location of files are 
# set here. There should be no reason to change any of this.
mkdir -p /opt/rtd/cache
mkdir -p /opt/rtd/scripts
mkdir -p /opt/rtd/log

# Base folder structure for optional administrative commandlets and scripts:
_RTDSCR=/opt/rtd/scripts
_RTDCACHE=/opt/rtd/cache
_RTDLOGSD=/opt/rtd/log

# Location of base administrative scripts and commandlets to get.
_RTDSRC=https://github.com/vonschutter/RTD-Build/archive/master.zip

# Determine log file directory
export _ERRLOGFILE=$_RTDLOGSD/$0-error.log
export _LOGFILE=$_RTDLOGSD/$0.log 
export _STATUSLOG=$_RTDLOGSD/$0-status.log

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#::::::::::::::                                          ::::::::::::::::::::::
#::::::::::::::          Execute tasks                   ::::::::::::::::::::::
#::::::::::::::                                          ::::::::::::::::::::::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

#:: Given that Bash or other Shell environment has been detected and the POSIX chell portion of this script is executed,
#:: the second stage script must be downloaded from an online location. Depending on the distribution of OS
#:: there are different methods available to get and run remote files. 
#::
#:: Table of evaluating family of OS and executing the appropriate action fiven the OS found.
#:: In this case it is easier to manage a straight table than a for loop or array:


tell_info() {
	echo "starting post install tasks..."
	echo "SYSTEM information:"
	echo "File system information: "
	mount
	echo "Block Devices: "
	lsblk
	echo "available space: "
	df -h
	echo "Process information: "
	ps aux
	
} 

task_setup_rtd_basics() {
	echo "Linux OS Found: Attempting to get instructions for Linux..."
	# Using a dirty way to forcibly ensure that wget and unzip are available on the system. 
	wget -q  $_RTDSRC -P $_RTDCACHE
	unzip -o -j $_RTDCACHE/master.zip -d $_RTDSCR  -x *.png *.md *.yml *.cmd && rm -v $_RTDCACHE/master.zip 
	echo "Instructions sucessfully retrieved..."
	chmod +x $_RTDSCR/*
	pushd /bin
	ln -f -s $_RTDSCR/rtd* .
	popd
}

task_setup_ssh_keys() {
	mkdir  -p --mode=0700 /root/.ssh && cat /opt/rtd/custom/userkey.pub > /root/.ssh/authorized_keys 
	mkdir --mode=0700 /home/tangarora/.ssh && cat /opt/rtd/custom/userkey.pub > /home/tangarora/.ssh/authorized_keys
	chown -R tangarora /home/tangarora/.ssh && chmod 0700 -R /home/tangarora/.ssh
}


tell_info &>> $_LOGFILE
task_setup_rtd_basics &>> $_LOGFILE
task_setup_ssh_keys &>> $_LOGFILE
