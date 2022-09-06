#!/bin/bash

echo "-------------------------------------------------"
echo "----- MARTOR DEVELOPMENT TOOLS // start.sh ------"
echo "-------------------------------------------------"
echo ""

CODESUBDOMAIN="code"
GUACAMOLESUBDOMAIN="guaca"
DOMAINNAME="$(uname -n).local"

CODE_URL="http://$DOMAINNAME:9981/"
SUPERADMIN_URL="http://$DOMAINNAME:9983"

CONTAINERS=("vsc")
STOPPED_CONTAINERS=() #"superadmin" "grafana" "gucamole" "sonarqube" "sonarqube-db"


#move to script path
cd -- "$(dirname "$0")" >/dev/null 2>&1



source ./utils/commons.sh
check_command_available docker
check_command_available docker-compose
echo ""


echo "Launching containers"
for i in "${CONTAINERS[@]}"; do
	launch_container $i
done
echo ""


echo "Stopping other unnecesary containers"
for i in "${STOPPED_CONTAINERS[@]}"; do
    stop_container $i
done


echo ""; echo ""
echo "All ready and running!!!!"
echo ""; echo ""
echo "Code:             $CODE_URL"
echo ""

exit 0
