#!/bin/bash
cd

curl -o /etc/network/interfaces https://raw.githubusercontent.com/mustafatoraman/openstack/beta/master/compute1/interfaces
curl -o /etc/hostname https://raw.githubusercontent.com/mustafatoraman/openstack/beta/master/compute1/hostname
curl -o /etc/hosts hhttps://raw.githubusercontent.com/mustafatoraman/openstack/beta/master/compute1/hosts
curl -o /root/install.sh https://raw.githubusercontent.com/mustafatoraman/openstack/beta/master/compute1/install.sh
reboot
