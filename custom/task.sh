#!/bin/bash
echo					-	RTD Post Installation Task Sequence      -
#::
#::
#:: 						Post Installation Task Sequence
#::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#:: Author(s):   	SLS, KLS, NB.  Buffalo Center, IA & Avarua, Cook Islands
#:: Version:	1.00
#::
#::
#:: Purpose: 	The purpose of the task sequence is to configure a Linux based PC to automatically 
#::		install useful applications after the first reboot. This is done to make it
#::		easier for an Original Equiment Manufacturer (OEM) to configure and sell 
#::		Linux based systems to happy customers. And for customers to be happy 
#::		high quality usefull applications need to be provided. In contrast to many other 
#::		preinstalled OEM applications you may encounter on a consumer focused (read commercial focused) 
#::		PC where trial software usually is provided, these applications are not there to make 
#::		customers pay even more. These are free and open source applications only. 
#::		
#::		This is accomplished by modifying the installation process of a Linux based system to
#::		automatically downlod an install these application when it is booted the first time. 
#::
#::		This task sequence should be added to the automatic installation process of the OEM installation
#::		process, a.k.a: preseed for Debian based, and kickstart for the RedHat lineage, as well as 
#::		AutoYast for SUsE. 
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



task_enable_oem_elevate_priv() {
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

	echo "Configuring LightDM....."
	if [[ -f /etc/lightdm/lightdm.conf ]]; then 
		cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.rtd-bak
	fi

cat << OEM_LXDM_LOGIN_OPTION > /etc/lightdm/lightdm.conf
# This configuration file was created by RTD Setup.
# You may safely replace this file with the original backed up: 
# /etc/lightdm/lightdm.conf.rtd-bak
# If this file is not there, then it wa not there to begin with
# and you can delete this file. 
[SeatDefaults]
autologin-user=$_OEM_USER
autologin-user-timeout=0
OEM_LXDM_LOGIN_OPTION

	echo "Configuring SDDM...."
	if [[ -f /etc/sddm.conf ]]; then 
		cp /etc/sddm.conf /etc/sddm.conf.rtd-bak
	fi

cat << OEM_SDDM_LOGIN_OPTION > /etc/sddm.conf
# This configuration file was created by RTD Setup.
# You may safely replace this file with the original backed up: 
# /etc/sddm.conf.rtd-bak
# If this file is not there, then it wa not there to begin with
# and you can delete this file. 
[Autologin]
User=$_OEM_USER
Session=plasma.desktop
OEM_SDDM_LOGIN_OPTION

	echo "Configuring GDM...."
	if [[ -f /etc/gdm3/daemon.conf ]]; then 
		cp /etc/gdm3/daemon.conf /etc/gdm3/daemon.conf.rtd-bak
	fi

cat << OEM_GDM3_LOGIN_OPTION > /etc/gdm3/daemon.conf
# This configuration file was created by RTD Setup.
# You may safely replace this file with the original backed up: 
# /etc/gdm3/daemon.conf.rtd-bak
# If this file is not there, then it wa not there to begin with
# and you can delete this file. 
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=$_OEM_USER
OEM_GDM3_LOGIN_OPTION

}



task_oem_ensure_elevated_gui () {
	# Some Debian and other Linux distribution do not allow gui apps to 
	# be run when invoked by "sudo" or in a root (system elevated authority) 
	# environment. To mitigate this some stemp may need to taken. 
	# Will work on Slackware as well as Debian to give root permission to open X programs.
	echo "xhost local:root" >> /home/$_OEM_USER/.bashrc  

	# Allows runing an X program as root
	touch /root/.bashrc
	echo "export XAUTHORITY=/home/$_OEM_USER/.Xauthority"
}


task_oem_autounlock_disk() {
	# Setup automatic unlocking of the encrypted system disk (encryption is default on RTD systems).
	# NOTE: This will render the encryption useless since the key to unlock the encrypted
	# volume will be located on an unencrypted location on the same system as the encrypted volume. 
	# This is the same as locking your door and leaving the key by the door outside. 
	#
	# The intention behind this is to be able to complete all build activites without manual intervention
	# of any kind. The intention is to remove the key file after all administrative tasks are complete. 

	# 1. Back up your initramfs disk
	cp  /boot/initrd.img-$(uname -r)  /boot/initrd.img-$(uname -r).bak

		# cat << OEM_CRYPTLOCK_OPTION > /boot/grub/grub.cfg
		#### BEGIN /etc/grub.d/10_linux ###
		#
		# menuentry 'Debian GNU/Linux, with Linux $(uname -r) (crypto safe)' --class debian --class gnu-linux --class gnu --class os {
		#       load_video
		#       insmod gzio
		#       insmod part_msdos
		#       insmod ext2
		#       set root='hd0,msdos1'
		#       search --no-floppy --fs-uuid --set=root 2a5e9b7f-2128-4a50-83b6-d1c285410145
		#       echo    'Loading Linux $(uname -r) ...'
		#       linux   /vmlinuz-$(uname -r) root=/dev/mapper/dradispro-root ro  quiet
		#       echo    'Loading initial ramdisk ...'
		#       initrd  /initrd.img-$(uname -r).safe
		# }
		# ...
		### END /etc/grub.d/10_linux ###
		# OEM_CRYPTLOCK_OPTION

	# 2. Create the key file in the unencrypted /boot partition
	dd if=/dev/urandom of=/boot/keyfile bs=1024 count=4

	# 3. Set permissions
	chmod 0400 /boot/keyfile

	# 4. Add the new file as unlock key to the encrypted volume
	echo letmein1234 | cryptsetup -v luksAddKey $(blkid | grep crypto_LUKS|  cut -d : -f 1) /boot/keyfile -

	# 6. Edit /etc/crypttab
	chmod 0777 /etc/crypttab
	cp /etc/crypttab /etc/crypttab.temporary
	sed -i /"$(cat /etc/crypttab | cut -d " " -f 1 )"/d /etc/crypttab.temporary 
	echo $(cat /etc/crypttab | cut -d " " -f 1-2)  /$(udevadm info $(blkid | grep crypto_LUKS|  cut -d : -f 1) |grep by-uuid | cut -d : -f 2 | head -1):/keyfile luks,keyscript=/lib/cryptsetup/scripts/pa$  >> /etc/crypttab.temporary
	mv /etc/crypttab /etc/crypttab.back
	mv /etc/crypttab.temporary /etc/crypttab

	# Restore permissions to crypttab
	chmod 0440 /etc/crypttab

	# Generate new initramfs
	mkinitramfs -o /boot/initrd.img-$(uname -r)  $(uname -r)

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
task_enable_oem_elevate_priv	&>> $_LOGFILE
task_ensure_oem_auto_login	&>> $_LOGFILE
task_oem_ensure_elevated_gui	&>> $_LOGFILE
#task_oem_autounlock_disk	&>> $_LOGFILE
