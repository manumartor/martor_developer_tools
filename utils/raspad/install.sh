#!/bin/bash

echo_dots(){
	local str="- $1"
	local strlen=${#str}

	for (( c=${strlen}; c<=41; c++ ))
	do
  		str+="."
	done

	echo -n "$str "
}


apt update
apt upgrade -y
echo_dots "Updating os"; echo "OK"


#virtual keyboard
echo_dots "Installing virtual keyboard"
apt install -y -qq onboard at-spi2-core
echo "OK"


#generic packages
echo_dots "Installing generic pakages"
apt install -y -qq htop vim git
echo "OK"


#right click
echo_dots "Installing right click"
apt install -y -qq tochegg
echo "OK"



#rotation screen
echo_dots "Installing rotation screen"
cd /tmp
git clone https://github.com/raspad-tablet/raspad-auto-rotator
cd raspad-auto-rotator
python3 install.py
cd ..
rm -rf raspad-auto-rotator
echo "OK"



#raspi commands
echo_dots "Installing raspi commands"
cat <<EOF > /usr/local/bin/raspi-temp
#!/bin/bash
# Shell script: temp.sh
# Autor: Santiago Crespo

cpu=$(cat /sys/class/thermal/thermal_zone0/temp)
echo "$(date) @ $(hostname)"
echo "-------------------------------------------"
echo "Temp.CPU => $((cpu/1000))'Cº"
echo "Temp.GPU => $(vcgencmd measure_temp)"
echo "-------------------------------------------"

echo ""
echo "Otros datos del sistema"
echo "-------------------------------------------"
echo "CPU $(vcgencmd measure_clock arm)'Hz"
echo "CPU $(vcgencmd measure_volts core)"
echo "Memoria repartida entre el sistema y la gpu:"
echo "Sistema $(vcgencmd get_mem arm)"
echo "GPU $(vcgencmd get_mem gpu)"
echo "-------------------------------------------"
echo "Memoria libre $(free -h)"
echo "-------------------------------------------"


exit 0
EOF

cat <<EOF > /usr/local/bin/raspi-temp
#!/bin/bash
# Shell script: temp.sh
# Autor: Santiago Crespo

cpu=$(cat /sys/class/thermal/thermal_zone0/temp)
echo "$(date) @ $(hostname)"
echo "-------------------------------------------"
echo "Temp.CPU => $((cpu/1000))'Cº"
echo "Temp.GPU => $(vcgencmd measure_temp)"
echo "-------------------------------------------"

exit 0
EOF

cat <<EOF >> /home/$USER/.bashrc
	# MARTOR CUSTOMIZATIONS
	alias l='ls -lah'
	alias d=docker
	alias dc=docker-compose
EOF

source /home/martor/.bashrc
echo "OK"


echo_dots "Rebooting system"
reboot -t 5
