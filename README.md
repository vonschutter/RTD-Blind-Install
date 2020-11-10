# Automatic network install ISO creator for Linux
![RTD Blind Install Media Builder](custom/rtd-mc.png?raw=true "Executing the Script")

Automatic Ubuntu/Kubuntu network install ISO creator.

Makes an ISO (Virtual CD) that will blindly install the Ubuntu flavor of choice on to a PC or a VM, no questions asked. 

All chices have been made for you: 
 ```
1 - All configuration decissions have been set to sensible ones
2 - Full disk encryption is enabled by default
!WARNING!  The PC that is booted from this media will be wiped completely! 
           There will be no prompt or warning! 

The installation media (ISO) vill be placed in your home folder. 
 ```
Simply use this virtual CD, in a virtual machine or use a handy tool to burn it to a USB or physical CD/DVD. 

## How to Use This Tool:
To use this tool, simply download the "rtd-mc" file along with the "custom" folder. This may be done using the "Clone/Download" button on this page. Then extract the files to a handy location. It is recommended to place them in a folder called "bin" in your home folder on Linux since scripts in here will be avaiable in any terminal started after executable files are placed there. 

The "custom" folder contains configurations etc. that will be included in the bootable media. Please feel free to alter these to your liking; notably the pre-populated passwords. 

To install and use this tool cut and baste the line below in to a terminal on your Linux machine:
```
mkdir -p ~/bin && wget https://github.com/vonschutter/RTD-Blind-Install/raw/master/rtd-blind-install -O ~/bin && chmod +x ~/bin/rtd-blind-install && echo All done! 
```

The simply run the script by typing:
```
~/bin/rtd-blind-install
```
or simply type the following in a new terminal: 
```
~/bin/rtd-blind-install
```
