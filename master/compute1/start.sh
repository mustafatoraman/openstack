#!/bin/bash

repo=https://raw.githubusercontent.com/mustafatoraman/openstack/master/master

cd

curl -o /etc/network/interfaces $repo/compute1/interfaces
curl -o /etc/hostname $repo/compute1/hostname
curl -o /etc/hosts $repo/compute1/hosts
curl -o /root/install.sh $repo/compute1/install.sh

reboot
