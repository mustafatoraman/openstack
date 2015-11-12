#!/bin/bash
cd

repo="https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/"

#Download Password file from controller node
scp root@controller:/root/passwords.sh /root/passwords.sh
rootpath=/root
. $rootpath/passwords.sh

#Download pw updater
curl -o /root/pw_update.sh $repo/pw_update.sh

#Configure NTP
apt-get -y install chrony
curl -o /etc/chrony/chrony.conf $repo/compute2/chrony.conf
service chrony restart

#Install OpenStack packages
apt-get -y install software-properties-common
add-apt-repository -y cloud-archive:liberty
apt-get -y update && apt-get -y dist-upgrade
apt-get -y install python-openstackclient

#Install and configure a compute node
apt-get -y install nova-compute sysfsutils
curl -o /etc/nova/nova.conf $repo/compute2/nova.conf
sh pw_update.sh /etc/nova/nova.conf
curl -o /etc/nova/nova-compute.conf $repo/compute2/nova-compute.conf
service nova-compute restart
rm -f /var/lib/nova/nova.sqlite

#Add the Networking service
apt-get -y install neutron-plugin-linuxbridge-agent
curl -o /etc/neutron/neutron.conf $repo/compute2/neutron.conf
curl -o /etc/neutron/plugins/ml2/linuxbridge_agent.ini  $repo/compute2/linuxbridge_agent.ini

sh pw_update.sh /etc/neutron/neutron.conf
sh pw_update.sh /etc/neutron/plugins/ml2/linuxbridge_agent.ini 

service nova-compute restart
service neutron-plugin-linuxbridge-agent restart

shutdown -h now
