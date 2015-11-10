#!/bin/bash
cd

curl -o /etc/network/interfaces https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/interfaces
curl -o /etc/hostname https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/hostname
curl -o /etc/hosts https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/hosts
curl -o /root/install.sh https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/install-beta.sh
