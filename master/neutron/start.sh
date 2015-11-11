#!/bin/bash
cd

#Download pw updater
curl -o /root/pw_update.sh https://raw.githubusercontent.com/mustafatoraman/openstack/beta/master/pw_update.sh

#Configure NTP
apt-get -y install chrony
curl -o /etc/chrony/chrony.conf https://raw.githubusercontent.com/mustafatoraman/openstack/beta/master/neutron/chrony.conf
service chrony restart

#download 
curl -o /etc/chrony/chrony.conf https://raw.githubusercontent.com/mustafatoraman/openstack/beta/master/neutron/install.sh

#Install OpenStack packages
apt-get -y install software-properties-common
add-apt-repository -y cloud-archive:liberty
apt-get -y update && apt-get -y dist-upgrade
apt-get -y install python-openstackclient
