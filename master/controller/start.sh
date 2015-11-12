#!/bin/bash

repo=https://raw.githubusercontent.com/mustafatoraman/openstack/master/master

curl -o /etc/network/interfaces $repo/controller/interfaces
curl -o /etc/hostname $repo/controller/hostname
curl -o /etc/hosts $repo/controller/hosts
curl -o /root/install.sh $repo/controller/install.sh

reboot
