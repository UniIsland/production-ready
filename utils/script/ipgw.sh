#!/bin/bash

# pku ipgw connector

# connection range: "2" for domestic, "1" for international
# timeout:
RANGE=2
TimeOut=0
PasswdFile="$HOME/.config/ipgw.conf"

case $1 in
    -l|--list)
        cat $PasswdFile | awk '{print $1}'
        exit 0
    ;;
    *)
        Profile="`expr "$1" : '\(\w*\)'`"
    ;;
esac

# read account info
[ -e "$PasswdFile" ] && grep -q ${Profile:=default} $PasswdFile || {
	echo "No account infomation available. Please specify."
	read -p "Username: " Username
	read -s -p "Password: " Password
    echo -n "${Profile:=default} " >> "$PasswdFile"
	echo -e "$Username\n$Password" | base64 >> "$PasswdFile"
	chmod 600 "$PasswdFile"
}
Username="`grep ${Profile:=default} "$PasswdFile" | awk '{print $2}' | base64 -d | head -n 1`"
Password="`grep ${Profile:=default} "$PasswdFile" | awk '{print $2}' | base64 -d | tail -n 1`"

wget -q --no-proxy -t 3 -O- --no-check-certificate  "https://ipgw.pku.edu.cn/ipgw/ipgw.ipgw?uid=$Username&password=$Password&timeout=$TimeOut&range=$RANGE&operation=disconnectall" | grep -q "SUCCESS=YES" && echo "Successfully disconnected." || echo "Failed to disconnect."

wget -q --no-proxy -t 3 -O- --no-check-certificate  "https://ipgw.pku.edu.cn/ipgw/ipgw.ipgw?uid=$Username&password=$Password&timeout=$TimeOut&range=$RANGE&operation=connect" | grep "SUCCESS=YES" | egrep -o 'BALANCE.....' && echo "Successfully connected." || echo "Failed to connect."
