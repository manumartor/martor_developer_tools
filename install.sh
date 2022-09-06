#!/bin/bash

echo "---------------------------------------------------"
echo "----- MARTOR DEVELOPMENT TOOLS // install.sh ------"
echo "---------------------------------------------------"
echo ""

#move to script path
cd -- "$(dirname "$0")" >/dev/null 2>&1

source ./utils/commons.sh
require_sudo

#update os
echo "Updating os"
apt update
apt upgrade -y


#install dependencies
#echo "Installing dependencies"
#apt install -y htop vim git


#install sshd
#echo "Installing sshd"
#./utils/install/install-sshd.sh


#install vcn openssh-server
#echo "Installing tightvncserver"
#./utils/install/install-vncserver.sh


#install docker
echo "Installing docker"
./utils/install/install-docker.sh


#customize bash cli
#echo "Installing bash cli customizations"
#./utils/install/install-bashrc.sh


#install mdt cli wrapper in to os
echo "Installing mdt cli wrapper"
./utils/install/install-mdt.sh


#install raspi commands
#echo "Installing raspi commands"
#./utils/install/install-raspicommands.sh

#install raspi fan controller
#echo "Installing raspi fan control"
#./utils/install/install-raspifancontrol.sh


echo ""; echo ""
exit 0
