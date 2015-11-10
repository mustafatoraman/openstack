#!/bin/bash
cd

curl -o /etc/network/interfaces https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/compute2/interfaces
curl -o /etc/hostname https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/compute2/hostname
curl -o /etc/hosts https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/compute2/hosts
curl -o /root/install.sh https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/compute2/install.sh
