#!/bin/bash
clear
read -r -p "15) Download and configure Neutron? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        echo "Starting..."
mysql -uroot -p$ROOT_DB_PASS -e "CREATE DATABASE neutron"
mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '$NEUTRON_DBPASS'"
mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '$NEUTRON_DBPASS'"
. $rootpath/admin-openrc.sh
openstack user create --domain default --password $NEUTRON_PASS neutron
openstack role add --project service --user neutron admin
openstack service create --name neutron --description "OpenStack Networking" network
openstack endpoint create --region RegionOne network public http://controller:9696
openstack endpoint create --region RegionOne network internal http://controller:9696
openstack endpoint create --region RegionOne network admin http://controller:9696
apt-get -y install neutron-server neutron-plugin-ml2 \
    neutron-plugin-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent \
    neutron-metadata-agent python-neutronclient

curl -o /etc/neutron/neutron.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/neutron.conf
curl -o /etc/neutron/plugins/ml2/ml2_conf.ini https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/ml2_conf.ini
curl -o /etc/neutron/plugins/ml2/linuxbridge_agent.ini https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/linuxbridge_agent.ini
curl -o /etc/neutron/l3_agent.ini https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/l3_agent.ini
curl -o /etc/neutron/dhcp_agent.ini https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/dhcp_agent.ini
curl -o /etc/neutron/dnsmasq-neutron.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/dnsmasq-neutron.conf
curl -o /etc/neutron/neutron.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/neutron.conf
curl -o /etc/neutron/metadata_agent.ini https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/metadata_agent.ini

sh pw_update.sh /etc/neutron/neutron.conf
sh pw_update.sh /etc/neutron/plugins/ml2/ml2_conf.ini
sh pw_update.sh /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sh pw_update.sh /etc/neutron/l3_agent.ini
sh pw_update.sh /etc/neutron/dhcp_agent.ini
sh pw_update.sh /etc/neutron/dnsmasq-neutron.conf
sh pw_update.sh /etc/neutron/metadata_agent.ini

su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
  --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
  
service nova-api restart
service neutron-server restart
service neutron-plugin-linuxbridge-agent restart
service neutron-dhcp-agent restart
service neutron-metadata-agent restart
service neutron-l3-agent restart

rm -f /var/lib/neutron/neutron.sqlite

sleep 5

rootpath=/root

. $rootpath/admin-openrc.sh
neutron net-create public --shared --provider:physical_network public --provider:network_type flat
neutron subnet-create public 9.100.16.0/24 --name public --allocation-pool start=9.100.16.10,end=9.100.16.254 --dns-nameserver 8.8.4.4 --gateway 9.100.16.1
. $rootpath/demo-openrc.sh
neutron net-create private
neutron subnet-create private 172.16.1.0/24 --name private --dns-nameserver 8.8.4.4 --gateway 172.16.1.1
. $rootpath/admin-openrc.sh
neutron net-update public --router:external
. $rootpath/demo-openrc.sh
neutron router-create router
neutron router-interface-add router private
neutron router-gateway-set router public
