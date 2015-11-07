#!/bin/bash
cd

#Download and run password generator
curl -o /root/pw.sh https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/pw.sh
sh pw.sh
rm -rf pw.sh

#Download pw updater
curl -o /root/pw_update.sh https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/pw_update.sh

#Load passwords
rootpath=/root
. $rootpath/passwords.sh

#Configure NTP
apt-get install chrony
curl -o /etc/chrony/chrony.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/chrony.conf
service chrony restart

#Install OpenStack packages
apt-get -y install software-properties-common
add-apt-repository -y cloud-archive:liberty
apt-get -y update && apt-get -y dist-upgrade
apt-get -y install python-openstackclient

#Install SQL database
echo mariadb-server-5.5 mysql-server/root_password password $ROOT_DB_PASS | debconf-set-selections
echo mariadb-server-5.5 mysql-server/root_password_again password $ROOT_DB_PASS | debconf-set-selections
apt-get -y install mariadb-server python-pymysql
curl -o /etc/mysql/conf.d/mysqld_openstack.cnf \
https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/mysqld_openstack.cnf
service mysql restart
apt-get -y install expect
curl -o /root/dbsec.sh https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/dbsec.sh
sh dbsec.sh
rm -rf dbsec.sh

#Install NoSQL database
apt-get -y install mongodb-server mongodb-clients python-pymongo
curl -o /root/mongodb.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/mongodb.conf
service mongodb restart

#Install Message Queue
apt-get -y install rabbitmq-server
rabbitmqctl add_user openstack $RABBIT_PASS
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

#Identity service
mysql -uroot -p$ROOT_DB_PASS -e "CREATE DATABASE keystone"
mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$KEYSTONE_DBPASS'"
mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$KEYSTONE_DBPASS'"
echo "manual" > /etc/init/keystone.override
apt-get -y install keystone apache2 libapache2-mod-wsgi memcached python-memcache
curl -o /etc/keystone/keystone.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/keystone.conf
sh pw_update.sh /etc/keystone/keystone.conf
su -s /bin/sh -c "keystone-manage db_sync" keystone

#Configure the Apache HTTP server
curl -o /etc/apache2/apache2.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/apache2.conf
curl -o /etc/apache2/sites-available/wsgi-keystone.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/wsgi-keystone.conf
ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled
service apache2 restart
rm -f /var/lib/keystone/keystone.db

#Create the service entity and API endpoints
export OS_TOKEN=$ADMIN_TOKEN
export OS_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
openstack service create --name keystone --description "OpenStack Identity" identity
openstack endpoint create --region RegionOne identity public http://controller:5000/v2.0
openstack endpoint create --region RegionOne identity internal http://controller:5000/v2.0
openstack endpoint create --region RegionOne identity admin http://controller:35357/v2.0

#Create projects, users, and roles
openstack project create --domain default --description "Admin Project" admin
openstack user create --domain default --password $ADMIN_PASS admin
openstack role create admin
openstack role add --project admin --user admin admin
openstack project create --domain default --description "Service Project" service
openstack project create --domain default --description "Demo Project" demo
openstack user create --domain default --password $DEMO_PASS demo
openstack role create user
openstack role add --project demo --user demo user

#Verify operation
sed -i 's/token_auth admin_token_auth/token_auth/g' /etc/keystone/keystone-paste.ini
unset OS_TOKEN OS_URL
openstack --os-auth-url http://controller:35357/v3 --os-project-domain-id default --os-user-domain-id default --os-project-name admin --os-username admin --os-password $ADMIN_PASS token issue
openstack --os-auth-url http://controller:5000/v3 --os-project-domain-id default --os-user-domain-id default --os-project-name demo --os-username demo --os-password $DEMO_PASS token issue


#Create OpenStack client environment scripts
curl -o /root/admin-openrc.sh https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/admin-openrc.sh
curl -o /root/demo-openrc.sh https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/demo-openrc.sh
sh pw_update.sh /root/admin-openrc.sh
sh pw_update.sh /root/demo-openrc.sh
. $rootpath/admin-openrc.sh
openstack token issue

#Add the Image service
mysql -uroot -p$ROOT_DB_PASS -e "CREATE DATABASE glance"
mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '$GLANCE_DBPASS'"
mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '$GLANCE_DBPASS'"
. $rootpath/admin-openrc.sh
openstack token issue
openstack user create --password $GLANCE_PASS glance
openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image service" image
openstack endpoint create --region RegionOne image public http://controller:9292
openstack endpoint create --region RegionOne image internal http://controller:9292
openstack endpoint create --region RegionOne image admin http://controller:9292
apt-get -y install glance python-glanceclient

curl -o /etc/glance/glance-api.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/glance-api.conf
curl -o /etc/glance/glance-registry.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/glance-registry.conf
sh pw_update.sh /etc/glance/glance-api.conf
sh pw_update.sh /etc/glance/glance-registry.conf

su -s /bin/sh -c "glance-manage db_sync" glance
service glance-registry restart
service glance-api restart
rm -f /var/lib/glance/glance.sqlite
. $rootpath/admin-openrc.sh
wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
glance image-create --name "cirros" --file cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --container-format bare --visibility public --progress
glance image-list

#Install and configure controller node
mysql -uroot -p$ROOT_DB_PASS -e "CREATE DATABASE nova"
mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$NOVA_DBPASS'"
mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '$NOVA_DBPASS'"
. $rootpath/admin-openrc.sh
openstack user create --domain default --password $NOVA_PASS nova
openstack role add --project service --user nova admin
openstack service create --name nova --description "OpenStack Compute" compute
openstack endpoint create --region RegionOne compute public http://controller:8774/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute internal http://controller:8774/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute admin http://controller:8774/v2/%\(tenant_id\)s
apt-get -y install nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient
curl -o /etc/nova/nova.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/nova.conf
sh pw_update.sh /etc/nova/nova.conf
su -s /bin/sh -c "nova-manage db sync" nova
service nova-api restart
service nova-cert restart
service nova-consoleauth restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart
rm -f /var/lib/nova/nova.sqlite

#Add the Networking service
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

#Networking Option 2: Self-service networks
apt-get install neutron-server neutron-plugin-ml2 \
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

