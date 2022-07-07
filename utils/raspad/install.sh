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


#generic packages
echo_dots "Installing generic pakages"; echo ""
apt install -y htop vim git lm-sensors
echo_dots "Installing generic pakages"; echo "OK"


#virtual keyboard
echo_dots "Installing virtual keyboard"; echo ""
apt install -y onboard at-spi2-core
echo_dots "Installing virtual keyboard"; echo "OK"


#right click
echo_dots "Installing right click"; echo ""
apt install -y touchegg
echo_dots "Installing right click"; echo "OK"



#rotation screen
echo_dots "Installing rotation screen"; echo ""
cd /tmp
git clone https://github.com/raspad-tablet/raspad-auto-rotator
cd raspad-auto-rotator
python3 install.py
cd ..
rm -rf raspad-auto-rotator
echo_dots "Installing rotation screen"; echo "OK"



#raspi commands
echo_dots "Installing raspi commands"
cat <<EOF > /usr/local/bin/raspi-info
#!/bin/bash
# Shell script: raspi.info.sh
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
chmod +x /usr/local/bin/raspi-info


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
chmod +x /usr/local/bin/raspi-temp

cat <<EOF >> /home/$(logname)/.bashrc
	# MARTOR CUSTOMIZATIONS
	alias l='ls -lah'
	alias d=docker
	alias dc=docker-compose
EOF
source /home/martor/.bashrc
echo "OK"


echo_dots "Rebooting system"
sleep 5
shutdown -r now
echo "OK"
