#!/bin/bash

#Here we can't use exit code from program (useraud, usercaps) because they have bug. BT-16583, BT-16581

#VARIABLES

#Colors and bold for letter
GREEN='\033[0;32m'
NORMAL='\033[0m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
BOLD_RED='\033[0;31;1m'
BOLD_GREEN='\033[0;32;1m'

textReturn=''


#FUNCTIONS

#checkReturnCode()
#{
#     if [ $? -ne 0 ]  #Success when fail
#    then
#        echo -e "$1 ${GREEN}is OK.${NORMAL}"
#    else
#        echo -e "${RED}Something went wrong. Execution aborted.${NORMAL}"
#        exit 1
#    fi
#}

checkReturnText()
{ 
#First,second argument is block scenario, third and fourth argument is negative scenario
	
	textReturn=`cat /tmp/scr.log`

	if echo "${textReturn}" | grep "${1}" &> /dev/null; then
		echo -e "	Block scenario is ${GREEN}OK.${NORMAL}"
	elif echo "${textReturn}" | grep "${2}" &> /dev/null; then
		echo -e "	Block scenario is ${GREEN}OK.${NORMAL}"
	else
		echo -e "${RED}String '${1}' or '${2}' not found.${NORMAL}"
		exit 1
	fi

	if echo "${textReturn}" | grep "${3}" &> /dev/null; then
		echo -e "${RED}Forbidden string '${3}' found${NORMAL}"
		exit 2
	elif echo "${textReturn}" | grep "${4}" &> /dev/null; then
		echo -e "${RED}Forbidden string '${4}' found${NORMAL}"
		exit 3
	else echo -e "	Negative scenario is ${GREEN}OK.${NORMAL}"
	fi
}


#MAIN

case "$1" in

smol)

	#User check
	if [[ "$USER" != "sniper" ]]; then
		echo -e "${RED}User must be 'target'${NORMAL}"
		exit 4
	fi

	#Attempts take access secret information
	echo -e "${BOLD}Pdpl-user${NORMAL}"
	/usr/sbin/pdpl-user target &> /tmp/scr.log
	checkReturnText "Permission denied " "Отказано в доступе" "минимальная метка" "minimal pdpl"

	echo -e "${BOLD}Usercaps${NORMAL}"
	/usr/sbin/usercaps target &> /tmp/scr.log
	checkReturnText "cannot read" "невозможно произвести чтение" "parsec_cap_chmac" "parsec_cap_chmac"

	echo -e "${BOLD}Useraud${NORMAL}"
	/usr/sbin/useraud target &> /tmp/scr.log
	checkReturnText "Permission denied" "Отказано в доступе" "target" "target"

	echo -e "${BOLD}Repquota${NORMAL}"
	/usr/sbin/repquota / &> /tmp/scr.log
	checkReturnText "Operation not permitted" "Операция не позволена" "Report for user quotas on device" "Report for user quotas on device"

	#Notification about success
	echo -e "${BOLD_GREEN}SCRIPT COMPLETED SUCCESSFULLY${NORMAL}"
	
;;
orel)

	#User check
	if [[ "$USER" != "sniper" ]]; then
		echo -e "${RED}User must be 'target'${NORMAL}"
		exit 4
	fi

	#Attempt take access secret information
	echo -e "${BOLD}Repquota${NORMAL}"
	/usr/sbin/repquota / &> /tmp/scr.log
	checkReturnText "Operation not permitted" "Отказано в доступе" "Report for user quotas on device" "Report for user quotas on device"

	#Notification about success
	echo -e "${BOLD_GREEN}SCRIPT COMPLETED SUCCESSFULLY${NORMAL}"
	
;;
prepare)

	#User check
	if [[ "$USER" != "root" ]]; then
		echo -e "${RED}User must be 'root'${NORMAL}"
		exit 5
	fi

	#Checking sniper home directory
	if [[ -d /home/sniper ]]; then
		echo "User 'sniper' is found"
	else
		echo -e "${RED}User 'sniper' and he home folder not found. Run ./user_scope.sh and make 'sniper' loggin first.${NORMAL}"
		exit 6
	fi

	#Copy script from testlink folder to sniper home directory
	cp /media/sf_svn/skts-test/testlink/user_scope_commands.sh /home/sniper
	chmod 777 /home/sniper/user_scope_commands.sh
	chown sniper:sniper /home/sniper/user_scope_commands.sh
	echo -e "${GREEN}Done${NORMAL}"

;;
*)

	#Notification about using arguments
	echo -e "${YELLOW}You must using next arguments:${NORMAL}"
	echo -e "./user_scope_commands.sh ${YELLOW}prepare${NORMAL}"
	echo -e "./user_scope_commands.sh ${YELLOW}smol${NORMAL}"
	echo -e "./user_scope_commands.sh ${YELLOW}orel${NORMAL}"
	exit 1         	

;;

esac
exit 0
