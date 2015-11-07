#!/bin/bash

#Download Password file from controller node
scp root@controller:/root/passwords.sh /root/passwords.sh
rootpath=/root
. $rootpath/passwords.sh

#Configure NTP
apt-get install chrony
curl -o /etc/chrony/chrony.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/compute1/chrony.conf
service chrony restart

#Install OpenStack packages
apt-get -y install software-properties-common
add-apt-repository -y cloud-archive:liberty
apt-get -y update && apt-get -y dist-upgrade
apt-get -y install python-openstackclient

#Install and configure a compute node
apt-get -y install nova-compute sysfsutils
curl -o /etc/nova/nova.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/compute1/nova.conf
sed -i "s/RABBIT_PASS/$RABBIT_PASS/g" /etc/nova/nova.conf
sed -i "s/NOVA_PASS/$NOVA_PASS/g" /etc/nova/nova.conf
sed -i "s/NEUTRON_PASS/$NEUTRON_PASS/g" /etc/nova/nova.conf
curl -o /etc/nova/nova-compute.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/compute1/nova-compute.conf
service nova-compute restart
rm -f /var/lib/nova/nova.sqlite
