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
#	NOTE:	This terminal program is written and documented to a very high degree. The reason for doing this is that
#		these apps are seldom changed and when they are, it is usefull to be able to understand why and how 
#		things were built. Obviously, this becomes a useful learning tool as well; for all people that want to 
#		learn how to write admin scripts. It is a good and necessary practice to document extensively and follow
#		patterns when building your own apps and config scripts. Failing to do so will result in a costly mess
#		for any organization after some years and people turnover. 
#
#		As a general rule, we prefer using functions extensively because this makes it easier to manage the script
#		and facilitates several users working on the same scripts over time.
#		
# 
#	RTD admin scrips are placed in /opt/rtd/scripts. Optionally scripts may use the common
#	functions in _rtd_functions and _rtd_recipies. 
#	  _rtd_functions -- contain usefull admin functions for scripts, such as "how to install software" on different systems. 
#	  _rtd_recipies  -- contain software installation and configuration "recipies". 
#	Scripts may also be stand-alone if there is a reason for this. 
#
#	Taxonomy of this script: we prioritize the use of functions over monolithic script writing, and proper indentation
#	to make the script more readable. Each function shall also be documented to the point of the obvious.
#	Suggested function structure per google guidelines:
#
#	function_name () {
#		# Documentation and comments... 
#		...code...
#	}
#
#	We also like to log all activity, and to echo status output to the screen in a frienly way. To accomplish this,
#	the table below may be used as appropriate: 
#


#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#::::::::::::::                                          ::::::::::::::::::::::
#::::::::::::::          Script Settings                 ::::::::::::::::::::::
#::::::::::::::                                          ::::::::::::::::::::::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# Variables that govern the behavior or the script and location of files are 
# set here. There should be no reason to change any of this.


# Base folder structure for optional administrative commandlets and scripts:
_RTDSCR=$(if [ -f /opt/rtd/scripts ]; then echo /opt/rtd/scripts ; else ( mkdir -p /opt/rtd/scripts & echo  /opt/rtd/scripts ) ; fi )
_RTDCACHE=$(if [ -f /opt/rtd/cache ]; then echo /opt/rtd/cache ; else ( mkdir -p /opt/rtd/cache & echo  /opt/rtd/cache ) ; fi )
_RTDLOGSD=$(if [ -f /opt/rtd/log ]; then echo /opt/rtd/log ; else ( mkdir -p /opt/rtd/log & echo  /opt/rtd/log ) ; fi )

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
	for i in apt yum dnf zypper ; do $i -y install wget &>> $_LOGFILE ; done
	wget -q  $_RTDSRC -P $_RTDCACHE &>> $_LOGFILE
	for i in apt yum dnf zypper ; do $i -y install unzip &>> $_LOGFILE ; done
	unzip -o -j $_RTDCACHE/master.zip -d $_RTDSCR  -x *.png *.md *.yml *.cmd &>> $_LOGFILE && rm -v $_RTDCACHE/master.zip &>> $_LOGFILE
		if [ $? -eq 0 ]
		then
			echo "Instructions sucessfully retrieved..."
			chmod +x $_RTDSCR/*
			pushd /bin
			ln -f -s $_RTDSCR/rtd* .
			popd
			 
		else
			echo "Failed to retrieve instructions correctly! " 
			echo "Suggestion: check write permission in "/opt" or internet connectivity."
			exit 
		fi
}

task_setup_ssh_keys() {
	mkdir  -p --mode=0700 /root/.ssh && cat /opt/rtd/custom/userkey.pub > /root/.ssh/authorized_keys 
	mkdir --mode=0700 /home/tangarora/.ssh && cat /opt/rtd/custom/userkey.pub > /home/tangarora/.ssh/authorized_keys
	chown -R tangarora /home/tangarora/.ssh && chmod 0700 -R /home/tangarora/.ssh
}


tell_info &>> $_LOGFILE
task_setup_rtd_basics &>> $_LOGFILE
task_setup_ssh_keys &>> $_LOGFILE



