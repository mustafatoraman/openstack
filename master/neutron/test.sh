#!/bin/bash


RUN ON OPENSTACK NODE

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



RUN ON NEUTRON NODE

apt-get -y install apache2 libapache2-mod-wsgi memcached python-memcache
curl -o /etc/apache2/apache2.conf https://raw.githubusercontent.com/mustafatoraman/openstack/beta/master/neutron/apache2.conf
service apache2 restart


apt-get -y install neutron-server neutron-plugin-ml2 \
    neutron-plugin-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent \
    neutron-metadata-agent python-neutronclient

curl -o /etc/neutron/neutron.conf https://raw.githubusercontent.com/mustafatoraman/openstack/beta/master/neutron/neutron.conf
curl -o /etc/neutron/plugins/ml2/ml2_conf.ini https://raw.githubusercontent.com/mustafatoraman/openstack/beta/master/neutron/ml2_conf.ini
curl -o /etc/neutron/plugins/ml2/linuxbridge_agent.ini https://raw.githubusercontent.com/mustafatoraman/openstack/beta/master/neutron/linuxbridge_agent.ini
curl -o /etc/neutron/l3_agent.ini https://raw.githubusercontent.com/mustafatoraman/openstack/beta/master/neutron/l3_agent.ini
curl -o /etc/neutron/dhcp_agent.ini https://raw.githubusercontent.com/mustafatoraman/openstack/beta/master/neutron/dhcp_agent.ini
curl -o /etc/neutron/dnsmasq-neutron.conf https://raw.githubusercontent.com/mustafatoraman/openstack/beta/master/neutron/dnsmasq-neutron.conf
curl -o /etc/neutron/metadata_agent.ini https://raw.githubusercontent.com/mustafatoraman/openstack/beta/master/neutron/metadata_agent.ini

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
