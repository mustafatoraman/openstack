#!/bin/bash
cd

curl -o /etc/network/interfaces https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/compute1/interfaces
curl -o /etc/hostname https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/compute1/hostname
curl -o /etc/hosts https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/compute1/hosts
