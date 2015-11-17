#!/bin/bash
rootpath=/root
. $rootpath/config.sh

sleep 3
echo "Downloading /etc/network/interfaces file" >> logs
curl -o /etc/network/interfaces $repo/$hostname/interfaces >> logs
echo "Downloading /etc/hostname file" >> logs
sleep 1
curl -o /etc/hostname $repo/$hostname/hostname >> logs
echo "Downloading /etc/hosts file" >> logs
sleep 1
curl -o /etc/hosts $repo/$hostname/hosts >> logs
