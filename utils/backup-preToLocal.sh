#!/bin/bash

#DEST=~/Backups/pre.martor.es-ubuntudesktop21/
DEST=/d/BACKUPS/BACKUP-PRE1.MARTOR.ES-UBUNTUDESKTOP21

mkdir -p $DEST
rsync -rauhvz --rsh='ssh -p9922' --progress martor@pre.martor.es:/home/martor/Proyectos $DEST

