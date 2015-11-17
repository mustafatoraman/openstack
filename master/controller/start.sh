#!/bin/bash
rootpath=/root
. $rootpath/include.sh

curl -o /etc/network/interfaces $repo/controller/interfaces
curl -o /etc/hostname $repo/controller/hostname
curl -o /etc/hosts $repo/controller/hosts
curl -o /root/install.sh $repo/controller/install.sh
