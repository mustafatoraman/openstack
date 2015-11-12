#!/bin/bash

cd

repo=https://raw.githubusercontent.com/mustafatoraman/openstack/master/master

file="/dev/sdb"
if [ -e "$file" ]
then
blockdisk=/dev/sdb
else
blockdisk=/dev/vdb
fi

#Download Password file from controller node
scp root@controller:/root/passwords.sh /root/passwords.sh
rootpath=/root
. $rootpath/passwords.sh

#Download pw updater
curl -o /root/pw_update.sh $repo/pw_update.sh

#Configure NTP
apt-get -y install chrony
curl -o /etc/chrony/chrony.conf $repo/block1/chrony.conf
service chrony restart

#Install OpenStack packages
apt-get -y install software-properties-common
add-apt-repository -y cloud-archive:liberty
apt-get -y update && apt-get -y dist-upgrade
apt-get -y install python-openstackclient

#Install and configure a storage node
apt-get -y install lvm2
pvcreate $blockdisk
vgcreate cinder-volumes $blockdisk
curl -o /etc/lvm/lvm.conf $repo/block1/lvm.conf

if [ -e "$file" ]
then
sleep 0
else
sed -i "s/sdb/vdb/g" /etc/lvm/lvm.conf
fi

apt-get -y install cinder-volume python-mysqldb
curl -o /etc/cinder/cinder.conf $repo/block1/cinder.conf
sh pw_update.sh /etc/cinder/cinder.conf
service tgt restart
service cinder-volume restart
rm -f /var/lib/cinder/cinder.sqlite

shutdown -h now

#apt-get install python-pip
#pip install ceilometermiddleware
