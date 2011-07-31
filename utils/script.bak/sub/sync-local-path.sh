#!/bin/bash

SrcDir=/home/source/developement/sandbox-46610

sudo chmod -R +x $SrcDir/bin $SrcDir/sbin $SrcDir/rc
sudo rsync -r --exclude '*.swp' $SrcDir/sbin $SrcDir/bin /usr/local/
sudo rsync -r --exclude '*.swp' $SrcDir/rc/ /etc/init.d/
