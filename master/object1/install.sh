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
curl -o /etc/chrony/chrony.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/object1/chrony.conf
service chrony restart

#Install OpenStack packages
apt-get -y install software-properties-common
add-apt-repository -y cloud-archive:liberty
apt-get -y update && apt-get -y dist-upgrade
apt-get -y install python-openstackclient

apt-get -y install xfsprogs rsync
mkfs.xfs /dev/sdb
mkfs.xfs /dev/sdc
mkdir -p /srv/node/sdb
mkdir -p /srv/node/sdc
echo "/dev/sdb /srv/node/sdb xfs noatime,nodiratime,nobarrier,logbufs=8 0 2" >> /etc/fstab
echo "/dev/sdc /srv/node/sdc xfs noatime,nodiratime,nobarrier,logbufs=8 0 2" >> /etc/fstab
mount /srv/node/sdb
mount /srv/node/sdc

curl -o /etc/rsyncd.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/object1/rsyncd.conf
curl -o /etc/default/rsync https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/object1/rsync
service rsync start

apt-get -y install swift swift-account swift-container swift-object

curl -o /etc/swift/object-server.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/object1/object-server.conf
curl -o /etc/swift/container-server.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/object1/container-server.conf
curl -o /etc/swift/account-server.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/object1/account-server.conf

chown -R swift:swift /srv/node
mkdir -p /var/cache/swift
chown -R root:swift /var/cache/swift
