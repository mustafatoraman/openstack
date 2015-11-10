#!/bin/bash

curl -o /etc/network/interfaces https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/block1/interfaces
curl -o /etc/hostname https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/block1/hostname
curl -o /etc/hosts https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/block1/hosts
curl -o /root/install.sh https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/block1/install.sh
reboot
