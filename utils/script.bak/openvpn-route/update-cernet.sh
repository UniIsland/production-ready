#!/bin/bash

workDir=/home/remote/eduvpn/route
listFile="$workDir/cernet.list"

wget -O- https://its.pku.edu.cn/oper/liebiao.jsp | grep "255." | grep -v "255.255.25" | awk '{print $1" "$3}' > "$listFile.new"
