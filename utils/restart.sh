#!/bin/bash

echo "--------------------------------------------------------------"
echo "----- MAIO.IO CLOUD-DOCKER // singlerestart.sh UTIL ----------"
echo "--------------------------------------------------------------"

echo ""

CONT=$1

if [ -z "$CONT" ] 
then
	echo "Before restart please choose a conteiner name!!"
	docker ps
	exit
fi

docker-compose kill $CONT && docker-compose rm -f $CONT && docker-compose build --force-rm $CONT && docker-compose up -d $CONT

echo ""
echo "-->> Restart status:"

docker-compose ps

if [ -d "$CONT-customizations" ] && [[ -f "$CONT-customizations/postinstall.sh" ]]; then
	echo "Executing postinstall...."
	./$CONT-customizations/postinstall.sh
fi

docker-compose logs -f $CONT
