#!/bin/bash

curl -o /etc/network/interfaces https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/block1/interfaces
service network restart
curl -o /etc/hostname https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/block1/hostname
hostname block1
curl -o /etc/hosts https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/block1/hosts
