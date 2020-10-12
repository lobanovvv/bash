#!/bin/bash

#VARIABLES

red='tput setaf 1'
green='tput setaf 2'
yellow='tput setaf 3'
bold='tput bold'
styleClear='tput sgr0'


#FUNCTION

checkFileExist(){
	if [[ -e $1 ]]
	then
		echo $1
		local len=$1
		tput cuu1; tput cuf $(( ${#len} + 1 ))
		$green; echo Exist; $styleClear
	else
		echo $1
		local len=$1
		tput cuu1; tput cuf $(( ${#len} + 1 ))
		$yellow; echo 'Not found';  $styleClear
	fi
}

tput clear


#MAIN

while true
do
	#Grep config
	$bold; echo '  Openvpn config '; $styleClear; echo

	grep --color '^server' /etc/openvpn/server.conf
	grep --color '^port' /etc/openvpn/server.conf
	grep --color '^cipher' /etc/openvpn/server.conf
	
	#Key and Crt files exist
	echo
	echo

	$bold; echo '  Are keys and certificates exist?'; $styleClear
	echo

	pathToServerCrt=$(grep ^cert /etc/openvpn/server.conf | cut -f2 -d ' ')
	pathToCaCrt=$(grep ^ca /etc/openvpn/server.conf | cut -f2 -d ' ')
	pathToPrivedKey=$(grep ^key /etc/openvpn/server.conf | cut -f2 -d ' ')
	pathToDiffi=$(grep ^dh /etc/openvpn/server.conf | cut -f2 -d ' ')
	pathToTls=$(grep ^tls-auth /etc/openvpn/server.conf | cut -f2 -d ' ')

	checkFileExist "$pathToServerCrt"
	checkFileExist "$pathToCaCrt"
	checkFileExist "$pathToPrivedKey"
	checkFileExist "$pathToDiffi"
	checkFileExist "$pathToTls"


	#Refresh timer
	echo
	tput civis
	echo -n 'Refresh timer: '; tput sc
	echo -n '2'; tput rc; sleep 1
	echo -n '1'; tput rc; sleep 1
	tput sgr0

	tput clear
done
