#!/bin/bash

#VARIABLES

#COLORS AND BOLD FOR LETTERS
NORMAL='\033[0m'
GREEN='\033[0;32m' 
RED='\033[0;31m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
BOLDRED='\033[0;31;1m'

FAIL_COUNT=0


#FUNCTION

#Check return code. Zero - ok, not zero - fail
checkReturnCode()
{
     if [ $? -eq 0 ]
     then
	     echo -e "$1 ${GREEN}OK${NORMAL}"
     else
	     echo -e "$1 ${RED}FAIL${NORMAL}"
	     FAIL_COUNT=$((FAIL_COUNT + 1))
     fi
}

#Check return code. Zero - fail, not zero - true
checkReturnCodeInvert()
{
     if [ $? -ne 0 ]
     then
	     echo -e "$1 ${GREEN}OK${NORMAL}"
     else
	     echo -e "$1 ${RED}FAIL${NORMAL}"
	     FAIL_COUNT=$((FAIL_COUNT + 1))
     fi
}


#MAIN

touch /tmp/xxx > /dev/null
checkReturnCode "Temporary file created"

pdp-ls -M /tmp/xxx | grep -q 'Уровень_0:Низкий:Нет:0x0'
checkReturnCode "Created file has level 0" 

setfattr -n security.PDPL -v '0sAQADAAM///////////8AAAAAAAAAAAAAAAA=' /tmp/xxx &> /dev/null | grep -iq отказано > /dev/null
checkReturnCodeInvert "Change the level without privileges" 

echo 1 > /parsecfs/unsecure_setxattr
checkReturnCode "Set special value if file" 

execaps -c 0x1000 -- setfattr -n security.PDPL -v '0sAQADAAM///////////8AAAAAAAAAAAAAAAA=' /tmp/xxx > /dev/null 
checkReturnCode "Change the level with privileges" 

pdp-ls -M /tmp/xxx | grep -q 'Уровень_3:Высокий:Категория_1,Категория_2,0xfffffffffffffffc:CCNRA' 
checkReturnCode "Check for changes" 

rm /tmp/xxx
checkReturnCode "Delete temporary file"

#Print result
if [ $FAIL_COUNT -eq 0 ]
then
	echo -e "\033[0;32;1mTEST PASSED${NORMAL}"
else
	echo -e "\033[0;31;1mTEST FAILED${NORMAL}"
fi

exit 0
