#!/bin/bash

# nodeenv.sh v1.6.0
#
# Changes:
# - v1.6.0: Put on working on Linux arm64
# - v1.5.0: Updated node version to v20.11.1 
# - v1.4.0: Try to control nodejs enviroment errors
# - v1.3.0: Updated node version to v18.16.0
# - v1.2.2: Changed node source download to curl
# - v1.2.2: Changed nodepath to $TMP folder
# - v1.2.1: Fix platform win detection for MINGW64_NT
# - v1.2.0: Refactorized node.zip download for be multiplatforms
# - v1.1.0: Added download node.zip if node folder not exists
# - v1.0.0: 1st development
#
# Used in:
# - martor-3d-verso
# - martor-constructron
# - martor-rdpjs
# - wuiwui
# - martor-api-template
# - martor-app-template

nodeversion="v20.11.1"
nodepath=$HOME/.nodejs


cd $(dirname "$0")

#detect platform
platform='unknown'
unamestr=$(uname)
if [[ "$unamestr" == 'Linux' ]]; then
    platform='linux'
elif [[ "${unamestr:0:10}" == 'MINGW64_NT' ]]; then
    platform='win'
fi
echo -e "\nPlatform: $platform"
echo -e "Unamestr: $unamestr"
echo ""

set_env(){
    if [[ "$platform" == 'linux' ]]; then
        export PATH=$PATH:$nodepath/bin
    else
        export PATH=$PATH:$nodepath
    fi
    export NODE_PATH=$nodepath/node_modules
}


#prepare nodejs enviroment if needed and nodejs already installed
if ! [ -x "$(command -v node)" ]; then
    if [[ -d "$nodepath" ]]; then
        echo -e "nodejs already installed at path $nodepath...\nlaunching it..."
        set_env
    fi
fi

#install nodejs if needed
if ! [ -x "$(command -v node)" ]; then
    echo "Installing nodejs...."
    downloadurl='unknown'
    if [[ "$platform" == 'linux' ]]; then
        apt-get install build-essential
        apt-get install cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev
        apt-get install python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev
        apt-get install libopencv-dev

        downloadurl="node-$nodeversion-linux-arm64"
        extension=".tar.xz"
        
        #https://nodejs.org/dist/v20.11.1/node-v20.11.1-linux-armv7l.tar.xz
        curl -SL "https://nodejs.org/dist/$nodeversion/$downloadurl$extension" -o $TEMP/nodejs-inst$extension 
        tar -xvf "$TEMP/nodejs-inst$extension" -C $TEMP
        rm $TEMP/nodejs-inst$extension
    elif [[ "$platform" == 'win' ]]; then
        #https://sourceforge.net/projects/opencvlibrary/files/opencv-win/3.4.3/opencv-3.4.3-vc14_vc15.exe/download

        downloadurl="node-$nodeversion-win-x64"
        extension=".zip"

        curl -SL "https://nodejs.org/dist/$nodeversion/$downloadurl$extension" -o $TEMP/nodejs-inst$extension 
        unzip $TEMP/nodejs-inst$extension -d $TEMP
        rm $TEMP/nodejs-inst$extension
    fi

    if ! [[ "$downloadurl" == 'unknown' ]]; then
        rm -rf $nodepath
        mkdir $nodepath
        mv $TEMP/$downloadurl/* $nodepath
        
        set_env
        echo -e "nodejs installed in path $nodepath... launching it...\n\n"
    fi
fi

if ! [ -x "$(command -v node)" ]; then
  echo -e "\n\n\nError: node is not installed.\n\n\n" >&2
  exit 1
fi

(
    $@
) || (
    # - v1.4.0: Try to control nodejs enviroment errors
    echo ""
    echo "Error launching nodejs script" 
    echo "If error is from nodejs enviroment try to execute:\n$ rm -rf $nodepath && ./nodeenv.sh $@"
)
