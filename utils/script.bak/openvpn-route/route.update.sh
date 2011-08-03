#!/bin/bash
smslibGateway=222.29.86.1

cat ./route.list | awk '{ print "route add -net "$1" netmask "$2" gw 222.29.86.1"}' > ./route.add.sh
cat ./route.list | awk '{ print "route del -net "$1" netmask "$2 }' > ./route.del.sh
