#!/bin/bash

workDir=/home/remote/eduvpn/route
listFile="$workDir/cn.list"

#wget -O- http://ftp.apnic.net/apnic/dbase/data/country-ipv4.lst | grep cn | awk '{ print $9" - "$11 }'| sort -n -u -t . -k 1,1 -k 2,2 -k 3,3 | sort -u | sort -n > "$listFile.new"
wget -O- http://ftp.apnic.net/apnic/dbase/data/country-ipv4.lst | grep cn | awk '{ print $9" - "$11 }'| sort -n -u -t . -k 1,1 -k 2,2 -k 3,3 > "$listFile.new"
