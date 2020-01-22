#!/bin/bash
echo				-	RTD System System Managment Bootstrap Script      -
#::
#::
#:: 						Shell Script Section
#::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#:: Author(s):   	SLS, KLS, NB.  Buffalo Center, IA & Avarua, Cook Islands
#:: Version:	1.00
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

# Base folder structure for optional administrative commandlets and scripts:
_RTDSCR=$(if [ -f /opt/rtd/scripts ]; then echo /opt/rtd/scripts ; else ( mkdir -p /opt/rtd/scripts & echo  /opt/rtd/scripts ) ; fi )
_RTDCACHE=$(if [ -f /opt/rtd/cache ]; then echo /opt/rtd/cache ; else ( mkdir -p /opt/rtd/cache & echo  /opt/rtd/cache ) ; fi )
_RTDLOGSD=$(if [ -f /opt/rtd/log ]; then echo /opt/rtd/log ; else ( mkdir -p /opt/rtd/log & echo  /opt/rtd/log ) ; fi )

# Location of base administrative scripts and commandlets to get.
_RTDSRC=https://github.com/vonschutter/RTD-Build/archive/master.zip

# Determine log file directory
_ERRLOGFILE=$_RTDLOGSD/post-install-error.log
_LOGFILE=$_RTDLOGSD/post-install.log
_STATUSLOG=$_RTDLOGSD/post-install-status.log

_OEM_USER=tangarora



#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#::::::::::::::                                          ::::::::::::::::::::::
#::::::::::::::          Define tasks to complete        ::::::::::::::::::::::
#::::::::::::::                                          ::::::::::::::::::::::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

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


task_setup_oem_run_once() {
	# Task to run the OEM post configuaration on first login. 
	# the OEM post configuration may allow for interaction if desired and would
	# best run on several distributions and in a full graphic environment. 

cat << CREATE_START_LINK > /etc/xdg/autostart/org.runtimedata.oem.cofig.desktop
# This will automatically start the RuntTime Data OEM config options on 
# the first login. Once run this launcher will be moved to the /opt/rtd folder
# so that subsequent logins will not be plagued by the OEM setup.
# 
[Desktop Entry]
Type=Application
Exec=sudo /opt/rtd/scripts/rtd-oem-linux-config.sh 
Terminal=true
Hidden=false
X-GNOME-Autostart-enabled=true
Name=Rintime Data Configuration Menu
Comment=start OEM configuration as user when you log in
CREATE_START_LINK

}


task_enable_oem_finish() {
	# Add instruction to a sudoers include file:
	# This should be removed when OEM setup is complete as it would represent a back door... 
	echo "tangarora ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/99_sudo_include_file

	# Check that your sudoers include file passed the visudo syntax checks:
	sudo visudo -cf /etc/sudoers.d/99_sudo_include_file
}



task_ensure_oem_auto_login() {
	# task to ensure that the temporary OEM user is loged in for 
	# admin purposes. It is better to install crtail software at this 
	# time since a full graphic environment is avaliable. Also the 
	# step 2 inst the OEM load process is optimally able to run 
	# on several distributions. 

	echo "Creating /etc/lightdm/lightdm.conf"
mkdir -p /etc/lightdm
cat << OEM_LXDM_LOGIN_OPTION > /etc/lightdm/lightdm.conf
[SeatDefaults]
autologin-user=$_OEM_USER
autologin-user-timeout=0
OEM_LXDM_LOGIN_OPTION

	echo "Creating /etc/sddm.conf.d/autologin.conf"
mkdir -p /etc/sddm.conf.d
cat << OEM_SDDM_LOGIN_OPTION > /etc/sddm.conf.d/autologin.conf

[Autologin]
User=$_OEM_USER
Session=plasma.desktop
OEM_SDDM_LOGIN_OPTION

}




#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#::::::::::::::                                          ::::::::::::::::::::::
#::::::::::::::          Execute tasks                   ::::::::::::::::::::::
#::::::::::::::                                          ::::::::::::::::::::::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

tell_info			&>> $_LOGFILE
task_setup_rtd_basics		&>> $_LOGFILE
task_setup_ssh_keys		&>> $_LOGFILE
task_setup_oem_run_once		&>> $_LOGFILE
task_enable_oem_finish		&>> $_LOGFILE
task_ensure_oem_auto_login	&>> $_LOGFILE
