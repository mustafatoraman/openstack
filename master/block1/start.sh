#!/bin/bash

repo=https://raw.githubusercontent.com/mustafatoraman/openstack/master/master

cd

curl -o /etc/network/interfaces $repo/block1/interfaces
curl -o /etc/hostname $repo/block1/hostname
curl -o /etc/hosts $repo/block1/hosts
curl -o /root/install.sh $repo/block1/install.sh

reboot
