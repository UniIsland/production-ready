#!/bin/bash
sudo route add -net $1 netmask $2 gw 10.16.0.129
