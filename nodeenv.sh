#!/bin/bash

# nodeenv.sh v1.3.0
#
# Changes:
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

nodeversion="v18.16.0"
nodepath=$TMP/node-v18


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


#prepare nodejs enviroment if needed and nodejs already installed
if ! [ -x "$(command -v node)" ]; then
    if [[ -d "$nodepath" ]]; then
        echo -e "nodejs already installed at path $nodepath...\nlaunching it..."
        export PATH=$PATH:$nodepath
        export NODE_PATH=$nodepath/node_modules
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

        downloadurl="node-$nodeversion-linux-x64"
        extension=".tar.xz"
    elif [[ "$platform" == 'win' ]]; then
        #https://sourceforge.net/projects/opencvlibrary/files/opencv-win/3.4.3/opencv-3.4.3-vc14_vc15.exe/download

        downloadurl="node-$nodeversion-win-x64"
        extension=".zip"
    fi

    if ! [[ "$downloadurl" == 'unknown' ]]; then
        curl -SL "https://nodejs.org/dist/$nodeversion/$downloadurl$extension" -o $TEMP/nodejs-inst.zip 
        unzip $TEMP/nodejs-inst.zip -d $TEMP
        rm $TEMP/nodejs-inst.zip
        rm -rf $nodepath
        mv $TEMP/$downloadurl $nodepath
        export PATH=$PATH:$nodepath
        export NODE_PATH=$nodepath/node_modules

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
    echo "Error launching app"
)
