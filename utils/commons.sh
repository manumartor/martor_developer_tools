cookiepath="/tmp/cookiefile"

echo_dots(){
	local str="- $1"
	local strlen=${#str}

	for (( c=${strlen}; c<=41; c++ ))
	do
  		str+="."
	done

	echo -n "$str "
}

check_command_available(){
	echo_dots $1

	if ! command -v $1 &> /dev/null
	then
    		echo "KO"
    		echo "Stop error: $1 could not be found"
    		exit 1
	else
    		echo "OK"
	fi
}

check_dependies(){
	echo "Cheking requeriments"
	check_command_available curl
	check_command_available sshd
	check_command_available tightvncserver
	check_command_available docker
	check_command_available docker-compose
	echo ""
}

require_sudo(){
	#check it's running as root
	if [ "$EUID" -ne 0 ];  then
		echo "STOP ERROR: Please run this script as root"
		echo ""; echo ""; echo ""
		exit 1
	fi
}

check_container(){
	echo_dots $1

	if [ -z `docker-compose ps -q $1` ] || [ -z `docker ps -q --no-trunc | grep $(docker-compose ps -q $1)` ]; then
  		echo "KO"
	else
  		echo "OK"
	fi

}

launch_container(){
	echo_dots $1

	if [ -z `docker-compose ps -q $1` ] || [ -z `docker ps -q --no-trunc | grep $(docker-compose ps -q $1)` ]; then
  		echo "KO"
  		docker-compose up -d $1
	else
  		echo "OK"
	fi
}

stop_container(){
        echo_dots $1

        if [ -z `docker-compose ps -q $1` ] || [ -z `docker ps -q --no-trunc | grep $(docker-compose ps -q $1)` ]; then
                echo "OK"
        else
                echo "KO"
		docker-compose stop $1
        fi
}

check_service(){
	echo_dots $1

	cmd="curl -k -o /dev/null -sw '%{http_code}\n' $2"
	status=$(eval $cmd)
	if [ ! $status -eq "200" ] && [ ! $status -eq "302" ]; then
		echo "KO $2 $status"
		echo "$cmd"
	else
		echo "OK"
	fi
}

check_websocket(){
	echo_dots $1

	cmd="curl -k -i -N -H 'Connection: Upgrade' -H 'Upgrade: websocket' -H 'Host: $APPSUBDOMAIN.$DOMAINNAME' -H 'Origin: https://$APPSUBDOMAIN.$DOMAINNAME' -o /dev/null -sw '%{http_code}\n' https://$APPSUBDOMAIN.$DOMAINNAME/$2/"
	status=$(eval $cmd)
	if [ ! $status -eq "200" ] && [ ! $status -eq "302" ]; then
		echo "KO wss://$APPSUBDOMAIN.$DOMAINNAME/$2/ $status"
		#echo "$cmd"
	else
		echo "OK"
	fi
}

launch_service(){
	echo_dots $1

	cmd="curl -k -o /dev/null -sw '%{http_code}\n' $2"
	status=$(eval $cmd)
	if [ ! $status -eq "200" ] && [ ! $status -eq "302" ]; then
		#echo "KO $2 $status"
		if [[ ! -f "$cookiepath" ]]; then
			#do login
			#url: http://pre.martor.es:9983/apiv1/
			#payload: {"schema":"login","data":{"login":"admin@martor.es","password":"nimda"}}
			payload='{"schema":"login","data":{"login":"admin@martor.es","password":"nimda"}}'
			cmd="curl -c $cookiepath -d '$payload' -H 'Content-Type: application/json' -X POST $SUPERADMIN_URL/apiv1/ 2>/dev/null"
			#echo "$cmd"
			resp=$(eval $cmd)
			#echo "$resp"
		fi
		#ask for reboot if needed
		#payload: {"schema":"apps_restart/lwdr001ga41d"}
		#resp: {"success":true}
		payload="{\"schema\":\"apps_restart/$3\"}"
		cmd="curl -b $cookiepath -d '$payload' -H 'Content-Type: application/json' -X POST $SUPERADMIN_URL/apiv1/ 2>/dev/null"
		#echo "$cmd"
		resp=$(eval $cmd)
		#echo "$resp"
		echo "OK services restarted!!"
	else
		echo "OK"
	fi
}

stop_service(){
	echo_dots $1

	cmd="curl -k -o /dev/null -sw '%{http_code}\n' $2"
	status=$(eval $cmd)
	if [ $status -eq "200" ] || [ $status -eq "302" ]; then
		#echo "KO $2 $status"
		if [[ ! -f "$cookiepath" ]]; then
			#do login
			#url: http://pre.martor.es:9983/apiv1/
			#payload: {"schema":"login","data":{"login":"admin@martor.es","password":"nimda"}}
			payload='{"schema":"login","data":{"login":"admin@martor.es","password":"nimda"}}'
			cmd="curl -c $cookiepath -d '$payload' -H 'Content-Type: application/json' -X POST $SUPERADMIN_URL/apiv1/ 2>/dev/null"
			#echo "$cmd"
			resp=$(eval $cmd)
			#echo "$resp"
		fi

		payload="{\"schema\":\"apps_stop/$3\"}"
		cmd="curl -b $cookiepath -d '$payload' -H 'Content-Type: application/json' -X POST $SUPERADMIN_URL/apiv1/ 2>/dev/null"
		#echo "$cmd"
		resp=$(eval $cmd)
		#echo "->$resp"
		echo "OK services stopped"
	else
		echo "OK"
	fi
}

check_port(){
	echo_dots $1

	cmd="sudo lsof -i:$2| grep LISTEN"
	state=$(eval $cmd)
	if [ -z "$state" ]; then
		echo "KO $2 NO_LISTEN"
		#echo "$cmd"
	else
		echo "OK"
	fi
}

check_unavailable_opened_ports(){
	echo_dots "Unavailable ports"

	cmd="lsof -i -P -n| grep LISTEN"
	output=$(eval $cmd)
	IFS='
'
	unavailable_ports=()
	for i in $output; do
		addr=$(echo $i| awk '{print $9;}')
		port="${addr##*:}"

		exists=0
		if [[ " ${PORTS_SERVICES[@]} " =~ " ${port} " ]]; then exists=1; fi

		if [ $exists -eq 0 ]; then
			if [[ ! " ${unavailable_ports[@]} " =~ " ${port} " ]]; then
				#echo "$port -> $exists"
				unavailable_ports+=($port)
			fi
		fi
	done

	if [ "${#unavailable_ports[@]}" -eq 0 ]; then
		echo "OK"
	else
		echo "KO ${unavailable_ports[@]}"
	fi
}

#check system updates are all up-to-date
check_system_is_uptodate(){
	echo_dots "Updates up-to-date"

	apt -qq -q update
	updates=$(/usr/lib/update-notifier/apt-check --human-readable)
	if [ ! $(echo $updates| awk '{print $4;}') -eq "0" ]; then
		echo "KO $updates"
	else
		#also check if threre is new release
		release=$(do-release-upgrade -c)
		if [[ $release == *"available"* ]]; then
			echo "KO"
			echo "$release"
		else
			echo "OK"
		fi
	fi
}


#memory enought free space
freemem_in_gb () {
    prec=$1;
    read -r _ freemem _ <<< "$(grep --fixed-strings 'MemFree' /proc/meminfo)"
    bc <<< "scale=${prec:-3};${freemem}/1024/1024"
}
check_system_memory(){
	echo_dots "Memory enought free space"

	memory=$(freemem_in_gb)
	if (( $(echo "$memory < 1" |bc -l) )); then
		echo "KO $memory"
	else
		echo "OK"
	fi
}

#check enought free disk space
check_system_disk(){
	echo_dots "Disk enought free space"

	memory=$( df --output=avail -h "$PWD" | sed '1d;s/[^0-9]//g')
	if (( $(echo "$memory < 5" |bc -l) )); then
		echo "KO $memory"
	else
		echo "OK"
	fi
}

#check system overload
check_system_overload(){
	echo_dots "System not overloaded"

	memory=$(cat /proc/loadavg| awk '{print $1;}')
	processors=$(nproc)
	if (( $(echo "$memory > $processors" |bc -l) )); then
		echo "KO $memory"
	else
		echo "OK"
	fi
}

check_system_temp(){
	echo_dots "System temperature"

	tmp=$(($(cat /sys/class/thermal/thermal_zone0/temp)/1000))
	if (( $(echo "$tmp > 75" |bc -l) )); then
		echo "KO $tmpºC"
	else
		echo "OK"
	fi
}
