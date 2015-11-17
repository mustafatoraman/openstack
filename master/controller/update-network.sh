#!/bin/bash
rootpath=/root
. $rootpath/config.sh

echo "Downloading /etc/network/interfaces file"
sleep1
curl -o /etc/network/interfaces $repo/$hostname/interfaces
clear
echo "Downloading /etc/hostname file"
sleep1
curl -o /etc/hostname $repo/$hostname/hostname
clear
echo "Downloading /etc/hosts file"
sleep1
curl -o /etc/hosts $repo/$hostname/hosts
clear
