#!/bin/bash

#check if node path not already set in ENVs
if [[ ! $PATH == *"martor_wifipass_getter/node/"* ]]; then
    export PATH=$PATH:$(pwd)/../../node
fi


npm i
node index.js


