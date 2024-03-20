#!/bin/bash

# nodeenv.sh launcher v1.1.0

tmpNodeEnvFile=./.nodeenv.sh

function on_exit() {
    echo "nodejs enviroment finished"
    rm -f ./.nodeenv.sh
}

(   
    if [ ! -f $tmpNodeEnvFile ]; then 
        echo "Preparing nodejs enviroment...."
        curl -L https://raw.githubusercontent.com/manumartor/martor_developer_tools/main/nodeenv.sh -o $tmpNodeEnvFile
        chmod +x $tmpNodeEnvFile
    fi
    
    trap on_exit EXIT

    $tmpNodeEnvFile $@
) || (
    echo "Error preparing nodejs enviroment"
)