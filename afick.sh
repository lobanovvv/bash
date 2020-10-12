#!/bin/bash


#VARIABLES

#Default color for letter
NORMAL='\033[0m'
#Green color for letter
GREEN='\033[0;32m'
#Red color for letter
RED='\033[0;31m'
#Yellow color for letter
YELLOW='\033[0;33m'
#Bold text (intensive color)
BOLD='\033[1m'
#Bold red text (intensive color)
BOLDRED='\033[0;31;1m'

#Directory with test files
scrDir='/aft'
    
    
#COMMON FUNCTION

checkReturnCode()                                                                             # with return code
{
    if [ $? -eq 0 ]
    then
        echo -e "$1 ${GREEN}OK.${NORMAL}"
    else
        echo -e "${RED}Something went wrong. Execution aborted.${NORMAL}"
        exit 1
    fi
}

#Check package exist
checkPackage()
{
    returnLang=$LANG

    if LANG=C.UTF-8; apt list afick 2>/dev/null | grep installed &> /dev/null
    then
        echo -e "Afick package installed ${GREEN}OK.${NORMAL}"
    else
        apt install afick -y
        echo -e "Afick package installed ${GREEN}OK.${NORMAL}"
    fi

    LANG=$returnLang
}                                                                                   

#Check os version
checkOsVersion()
{
    if grep -i orel /etc/astra_version 1>/dev/null
    then
        typeOs=orel
    elif grep -i smolensk /etc/astra_version 1>/dev/null
    then
        typeOs=smol
    else
        echo -e "${RED}You operation system not detected${NORMAL}"
        exit 1
    fi

    if [ $1 != $typeOs ]
    then
        echo -e "${RED}You operation system is not ${BOLDRED}$1${NORMAL}"
        exit 1
    fi
}
                                                                                    

#CASE with os version

case "$1" in
smol)

    #CHECKS

    #Check os version
    checkOsVersion $1
    #Check packages
    checkPackage

    #Cheking the launch of the script and erase changes.
    if [ -d $scrDir ]
    then
        rm -r /aft
        sed -i '/\/aft MyRule/d' /etc/afick.conf
        pdpl-file 0:0 /etc/fstab
        pdpl-file 0:0 /etc/
        echo -e "Restored setting after last start. ${GREEN}OK.${NORMAL}"
    fi

    #Check entry in afick config for fstab file
    grep "/etc/fstab PARSEC" /etc/afick.conf &> /dev/null
    if [ $? -ne 0 ]
    then
        echo -e "${RED}Afick configutation file have no entry for /etc/fstab${NORMAL}"
        exit 1
    else
        echo -e "Fstab rule exist in afick.conf  ${GREEN}OK.${NORMAL}"
    fi


    #MAIN

    #Create directory and files
    mkdir /aft && cd /aft && touch write perm atime &> /dev/null
    checkReturnCode "Directory and test files created."

    #Add rule for created directory in afick configuration file
    echo '/aft PARSEC' >> /etc/afick.conf
    checkReturnCode "Added rule to config."

    #Afick Initialization
    afick -i &> /dev/null
    checkReturnCode "Initialized afick data base."

    #Mandatory level up for fstab. Note, rule for fstab must be in /etc/afick.conf
    pdpl-file 1:0:0:ccnr /etc/ && pdpl-file 1:0 /etc/fstab &> /dev/null
    checkReturnCode "Mandatory level up for fstab"

    #Change directory and make changes to test file
    cd /aft/ && touch atime && echo Hello > write && chmod 111 perm &> /dev/null
    checkReturnCode "Changed directory and modified test files."

    #Run afick in compare mode. Save output in file
    afick -k 2> /dev/null 1> $HOME/tempFile.tp

    #Finding a line about changing atime test file
    grep "changed file : /aft/atime" < $HOME/tempFile.tp > /dev/null                    
    checkReturnCode "Entry about change atime exist."

    #Finding a line about changing permission test file
    grep "changed file : /aft/perm" < $HOME/tempFile.tp > /dev/null                     
    checkReturnCode "Entry about change permission exist."

    #Finding a line about writing in test file
    grep "changed file : /aft/write" < $HOME/tempFile.tp > /dev/null                    
    checkReturnCode "Entry about writing in file exist."

    #Finding a line about changing mandatory level for test file
    grep "changed file : /etc/fstab" < $HOME/tempFile.tp > /dev/null                    
    checkReturnCode "Entry about changing mandatory level for file exist."

    rm $HOME/tempFile.tp

    echo -e "\033[0;32;1m TEST PASSED${NORMAL}"

    exit 0
    ;;

orel)

    #CHECKS

    #Check os version
    checkOsVersion $1

    #Check packages
    checkPackage

    #Cheking the launch of the script and erase changes.
    if [ -d $scrDir ]
    then
        rm -r /aft
        sed -i '/\/aft MyRule/d' /etc/afick.conf
        echo -e "Restored setting after last start. ${GREEN}OK.${NORMAL}"
    fi

    #MAIN

    #Create directory and files
    mkdir /aft && cd /aft && touch write perm atime &> /dev/null
    checkReturnCode "Directory and test files created."

    #Add rule for created directory in afick configuration file
    echo '/aft MyRule' >> /etc/afick.conf
    checkReturnCode "Added rule to config."

    #Afick Initialization
    afick -i &> /dev/null
    checkReturnCode "Initialized afick data base."

    #Change directory and make changes to test file
    cd /aft/ && touch atime && echo Hello > write && chmod 111 perm &> /dev/null
    checkReturnCode "Changed directory and modified test files."

    #Run afick in compare mode. Save output in file
    afick -k 2> /dev/null 1> $HOME/tempFile.tp

    #Finding a line about changing atime test file
    grep "changed file : /aft/atime" < $HOME/tempFile.tp > /dev/null                    
    checkReturnCode "Entry about change atime exist."

    #Finding a line about changing permission test file
    grep "changed file : /aft/perm" < $HOME/tempFile.tp > /dev/null                     
    checkReturnCode "Entry about change permission exist."

    #Finding a line about writing in test file
    grep "changed file : /aft/write" < $HOME/tempFile.tp > /dev/null                    
    checkReturnCode "Entry about writing in file exist."

    rm $HOME/tempFile.tp

    echo -e "\033[0;32;1mTEST PASSED${NORMAL}"

    exit 0
;;

*)
    #If argument not exist
    echo -e "${YELLOW}You must using next argument:"
    echo -e "./afick.sh smol     for Astra Linux Smolensk"
    echo -e "./afick.sh orel     for Astra Linux Orel${NORMAL}"
    exit 1
;;

esac
