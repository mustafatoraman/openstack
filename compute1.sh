#!/bin/bash

echo "Starting setup for controller"
sleep 1
echo "Configuring public interface (eth1)"
sleep 1
wget -q https://raw.githubusercontent.com/mustafatoraman/openstack/master/compute1/interfaces -O /etc/network/interfaces
echo "Configuring hosts file"
sleep 1
wget -q https://raw.githubusercontent.com/mustafatoraman/openstack/master/compute1/hosts -O /etc/hosts

#Download Password file from controller node
scp root@controller:/root/passwords.sh /root/passwords.sh

#Load passwords
rootpath=/root
. $rootpath/passwords.sh

echo "Configuring Network Time Protocol"
sleep 1
apt-get -y install chrony
wget -q https://raw.githubusercontent.com/mustafatoraman/openstack/master/compute1/chrony.conf -O /etc/chrony/chrony.conf
echo "Reloading Chrony"
sleep 1
service chrony restart

echo "Enabling the OpenStack repository"
sleep 1
apt-get -y install software-properties-common
add-apt-repository -y cloud-archive:liberty
echo "Finalizing the installation"
sleep 1
apt-get -y update && apt-get -y dist-upgrade


echo "Installing the OpenStack client"
sleep 1
apt-get -y install python-openstackclient


echo "Install and configure components"
sleep 1
apt-get -y install nova-compute sysfsutils

#Download sample nova.conf for compute1 node
wget -q https://raw.githubusercontent.com/mustafatoraman/openstack/master/compute1/nova.conf -O /etc/nova/nova.conf

sed -i "s/RABBIT_PASS/$RABBIT_PASS/g" /etc/nova/nova.conf
sed -i "s/NOVA_PASS/$NOVA_PASS/g" /etc/nova/nova.conf

#Download sample nova.conf for compute1 node
wget -q https://raw.githubusercontent.com/mustafatoraman/openstack/master/compute1/nova-compute.conf -O /etc/nova/nova-compute.conf

#Restart the Compute service
service nova-compute restart

#Remove the SQLite database file
rm -f /var/lib/nova/nova.sqlite
