#!/bin/bash
rootpath=/root
. $rootpath/config.sh

sleep 3
clear
echo "Downloading /etc/network/interfaces file" 
curl -o /etc/network/interfaces $repo/$hostname/interfaces
sleep 1
clear
echo "Downloading /etc/hostname file"
sleep 1
curl -o /etc/hostname $repo/$hostname/hostname 
sleep 1
clear
echo "Downloading /etc/hosts file" 
sleep 1
curl -o /etc/hosts $repo/$hostname/hosts 
sleep 1
