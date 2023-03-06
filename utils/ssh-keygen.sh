#!/bin/bash

EMAIL=manu.martor@gmail.com
DEST=martor@pre.martor.es
PUBKEY_PATH=$HOME/.ssh/id_ed25519.pub

if [ ! -d "$HOME/.ssh" ]; then
    echo "Created .ssh folder"
    mkdir -p $HOME/.ssh
    chmod 0700 $HOME/.ssh
fi

if [ ! -f "$PUBKEY_PATH" ]; then
    echo "Generating public key"
    ssh-keygen -t ed25519 -C "$EMAIL"
else 
    echo "Public key already exists at path "
fi

echo "Copying public key to DEST"
ssh-copy-id -i $PUBKEY_PATH -p 9922 $DEST