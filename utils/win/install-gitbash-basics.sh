#!/bin/bash

#0. Download and install gitbash

#1. Install zstd
cd ~/Downloads

if [ ! -x "$(command -v zstd)" ]; then
	echo "Installig zstd"

	mkdir -p zstd
	cd zstd

	curl -L https://github.com/facebook/zstd/releases/download/v1.4.4/zstd-v1.4.4-win64.zip -o zstd-v1.4.4-win64.zip
	unzip zstd-v1.4.4-win64.zip
	
	mv ~/Downloads/zstd/zstd.exe /c/Program\ Files/Git/usr/bin/zstd.exe
	#echo "alias zstd=\"/c/Users/$USERNAME/Downloads/zstd/zstd.exe\"" >> ~/.bashrc
	#source ~/.bashrc
	
	cd ..
else
	echo "zstd already installed"
fi

#2. Add rsync to Git Bash for Windows 10
if [ ! -x "$(command -v rsync)" ]; then
	echo "Installing Rsync"

	mkdir -p rsync
	cd rsync
	
	curl -L https://repo.msys2.org/msys/x86_64/rsync-3.2.7-2-x86_64.pkg.tar.zst -o rsync-3.2.7-2-x86_64.pkg.tar.zst
	zstd -d rsync-3.2.7-2-x86_64.pkg.tar.zst
	tar -xvf rsync-3.2.7-2-x86_64.pkg.tar
	
	mv ~/Downloads/rsync/usr/bin/rsync.exe /c/Program\ Files/Git/usr/bin/rsync.exe
	ln -s /usr/bin/msys-crypto-1.1.dll /usr/bin/msys-crypto-3.dll
	#echo "alias rsync=\"/usr/bin/rsync.exe\"" >> ~/.bashrc
	#source ~/.bashrc
	
	cd ..	
else
	echo "Rsync already installed"
fi

#3. Acquiring the missing dll files for rsync
#packages repository: https://repo.msys2.org/msys/x86_64/

#3.1 libzstd
if ! [ -f "/c/Program\ Files/Git/usr/bin/msys-zstd-1.dll" ]; then
	echo "Installing libzstd"

	mkdir -p libzstd
	cd libzstd

	curl -L https://repo.msys2.org/msys/x86_64/libzstd-1.5.4-1-x86_64.pkg.tar.zst -o libzstd-1.5.4-1-x86_64.pkg.tar.zst
	zstd -d libzstd-1.5.4-1-x86_64.pkg.tar.zst
	tar -xvf libzstd-1.5.4-1-x86_64.pkg.tar

	mv ~/Downloads/libzstd/usr/bin/msys-zstd-1.dll /c/Program\ Files/Git/usr/bin

	cd ..
else
	echo "Libzstd already installed"
fi

#3.2 libxxhash
if [ ! -f "/c/Program\ Files/Git/usr/bin/msys-xxhash-0.dll" ]; then
	echo "Installing libxxhash"

	mkdir -p libxxhash
	cd libxxhash

	curl -L https://repo.msys2.org/msys/x86_64/libxxhash-0.8.1-1-x86_64.pkg.tar.zst -o libxxhash-0.8.1-1-x86_64.pkg.tar.zst
	zstd -d libxxhash-0.8.1-1-x86_64.pkg.tar.zst
	tar -xvf libxxhash-0.8.1-1-x86_64.pkg.tar

	mv ~/Downloads/libxxhash/usr/bin/msys-xxhash-0.dll /c/Program\ Files/Git/usr/bin
	cd ..
else
	echo "Libzstd already libxxhash"
fi

