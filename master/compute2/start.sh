#!/bin/bash

repo=https://raw.githubusercontent.com/mustafatoraman/openstack/master/master

cd

curl -o /etc/network/interfaces $repo/compute2/interfaces
curl -o /etc/hostname $repo/compute2/hostname
curl -o /etc/hosts $repo/compute2/hosts
curl -o /root/install.sh $repo/compute2/install.sh

reboot
