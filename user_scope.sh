#!/bin/bash
#set -e


#VARIABLES

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
clearColor=$(tput sgr0)


#FUNCTION

#Printing intermediate result 
echoResult() {
	if [[ $? == 0 ]]; then
		echo -e "$1 is ${green}OK${clearColor}"
	else
		echo -e "$1 is ${red}BAD${clearColor}"
		echo -e "${red}SCRIPT FAILED!${clearColor}"
		exit 1
	fi	
}

#Detecting os
if lsb_release -c | grep -i orel &> /dev/null; then
	echo -e "${yellow}Orel OS detected!${clearColor}"
	sleep 2
	OS="orel"
elif lsb_release -c | grep -i smolensk &> /dev/null; then
	echo -e "${yellow}Smolensk OS detected!${clearColor}"
	sleep 2
	OS="smolensk"
else
	echo -e "${yellow}OS not detected! What test set do you want start?${clearColor}"
	echo -n "${yellow}(O)rel or (S)molensk: ${clearColor}"
	read osSelection

	if [[ $osSelection == "O" ]] || [[ $osSelection == "o" ]]; then
		OS="orel"
	elif [[ $osSelection == "S" ]] || [[ $osSelection == "s" ]]; then 
		OS="smolensk"
	else
		echo -e "${red}You answer is not understanded. Program wait one letter S or O${clearColor}"
	fi
fi 


#MAIN

case $OS in
smolensk)

	echo -e "${yellow}Smolensk set:${clearColor}"
	
	echo data > /home/u/sign.me &> /dev/null
	echoResult "Create file for signature"

	#Create users
	yes 1 | adduser target --gecos "" &> /dev/null
	echoResult "Create user target"
	yes 1 | adduser sniper --gecos "" &> /dev/null
	echoResult "Create user sniper"
	
	#Adding various privileges
	useraud target -- ocxudntligarmphew:ocxudntligarmphew &> /dev/null
	echoResult "Audit for user target"

	useraud -o -- ocxudntligarmphew:ocxudntligarmphew &> /dev/null
	echoResult "Default audit"

	useraud -g target -- ocxudntligarmphew:ocxudntligarmphew &> /dev/null
	echoResult "Audit for group target"

	faillog -m 7 -u target &> /dev/null
	echoResult "Faillog for user target"

	usercaps -f target &> /dev/null
	echoResult "Usercaps for user target"

	pdpl-user -l 2:3 -i 63 -c 3:3 target &> /dev/null
	echoResult "Level,integrity,category for user target"

	#Quota set
	sudo mount -o remount,usrquota,grpquota / &> /dev/null
		echoResult "Quota: Remount / with quota properties"
	sed -i 's/remount-ro/remount-ro,usrquota,grpquota/' /etc/fstab &> /dev/null
		echoResult "Quota: Add to fstab quota properties"
	quotacheck -cugm / &> /dev/null
		echoResult "Quota: Check quota"
	quotaon -v / &> /dev/null
		echoResult "Quota: Quota on"
	setquota target 1G 1G 111 111 / &> /dev/null
		echoResult "Quota: Set quota for user target"
	
	#Notification about success
	echo -e "${green}SCRIPT COMPLETED SUCCESSFULLY${clearColor}"
;;
orel)
	echo -e "${yellow}Orel set:${clearColor}"

	#Create users
	yes 1 | adduser target --gecos "" &> /dev/null
	echoResult "Create user target"
	yes 1 | adduser sniper --gecos "" &> /dev/null
	echoResult "Create user sniper"
	
	#Adding various privileges

#	useraud target -- ocxudntligarmphew:ocxudntligarmphew &> /dev/null
#	echoResult "Audit for user target"
	
	faillog -m 7 -u target &> /dev/null
	echoResult "Faillog for user target"
	
#	usercaps -f target &> /dev/null
#	echoResult "Usercaps for user target"
#		
#	pdpl-user -l 2:3 -i 63 -c 3:3 target &> /dev/null
#	echoResult "Level,integrity,category for user target"
#		
	sudo mount -o remount,usrquota,grpquota / &> /dev/null
	echoResult "Quota: Remount / with quota properties"
	
	sed -i 's/remount-ro/remount-ro,usrquota,grpquota/' /etc/fstab &> /dev/null
	echoResult "Quota: Add to fstab quota properties"
	
	quotacheck -cugm / &> /dev/null
	echoResult "Quota: Check quota"
	
	quotaon -v / &> /dev/null
	echoResult "Quota: Quota on"
	
	setquota target 1G 1G 111 111 / &> /dev/null
	echoResult "Quota: Set quota for user target"
	
	#Notification about success
	echo -e "${green}SCRIPT COMPLETED SUCCESSFULLY${clearColor}"
	;;
esac
