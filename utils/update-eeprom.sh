#!/bin/bash

require_sudo(){
	#check it's running as root
	if [ "$EUID" -ne 0 ];  then
		echo ""
		echo "STOP ERROR: Please run this script as root"
		echo ""
		exit 1
	fi
}

echo_dots(){
	local str="- $1"
	local strlen=${#str}

	for (( c=${strlen}; c<=41; c++ ))
	do
  		str+="."
	done

	echo -n "$str "
}

require_sudo

echo_dots "Updating os"; echo ""
apt update
apt upgrade -y
echo_dots "Updating os"; echo "OK"


echo_dots "Installing package rpi-eeprom-update"; echo ""
apt-get install rpi-eeprom-update
echo_dots "OK"


echo ""; echo ""
rpi-eeprom-update

echo ""; echo ""; echo ""
echo "Please, reboot system executing: sudo shutdown -r now"
echo "And then exec again: rpi-eeprom-update [-a to perform update]"
echo "And if a update is done exec a reboot again"
echo ""

exit 0
