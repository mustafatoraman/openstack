#!/bin/bash
cd
#Download Password file from controller node
scp root@controller:/root/passwords.sh /root/passwords.sh
rootpath=/root
. $rootpath/passwords.sh

#Download pw updater
curl -o /root/pw_update.sh https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/pw_update.sh

#Configure NTP
apt-get install chrony
curl -o /etc/chrony/chrony.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/block1/chrony.conf
service chrony restart

#Install OpenStack packages
apt-get -y install software-properties-common
add-apt-repository -y cloud-archive:liberty
apt-get -y update && apt-get -y dist-upgrade
apt-get -y install python-openstackclient

#Install and configure a storage node
apt-get install lvm2
pvcreate /dev/sdb
vgcreate cinder-volumes /dev/sdb
curl -o /etc/lvm/lvm.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/block1/lvm.conf
apt-get -y install cinder-volume python-mysqldb
curl -o /etc/cinder/cinder.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/block1/cinder.conf
sh pw_update.sh /etc/cinder/cinder.conf
service tgt restart
service cinder-volume restart
rm -f /var/lib/cinder/cinder.sqlite

#apt-get install python-pip
#pip install ceilometermiddleware
