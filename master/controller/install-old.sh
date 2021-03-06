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

#Add the dashboard
apt-get -y install openstack-dashboard
curl -o /etc/openstack-dashboard/local_settings.py https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/local_settings.py
service apache2 reload

#Add the Block Storage service
mysql -uroot -p$ROOT_DB_PASS -e "CREATE DATABASE cinder"
mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY '$CINDER_DBPASS'"
mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY '$CINDER_DBPASS'"
. $rootpath/admin-openrc.sh
openstack user create --password $CINDER_PASS cinder
openstack role add --project service --user cinder admin
openstack service create --name cinder --description "OpenStack Block Storage" volume
openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2
openstack endpoint create --region RegionOne volume public http://controller:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volume internal http://controller:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volume admin http://controller:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 public http://controller:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 internal http://controller:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 admin http://controller:8776/v2/%\(tenant_id\)s
apt-get -y install cinder-api cinder-scheduler python-cinderclient
curl -o /etc/cinder/cinder.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/cinder.conf
sh pw_update.sh /etc/cinder/cinder.conf
su -s /bin/sh -c "cinder-manage db sync" cinder
service nova-api restart
service cinder-scheduler restart
service cinder-api restart
rm -f /var/lib/cinder/cinder.sqlite

#Add the Object Storage service
. $rootpath/admin-openrc.sh
openstack user create --domain default --password $SWIFT_PASS swift
openstack role add --project service --user swift admin
openstack service create --name swift --description "OpenStack Object Storage" object-store
openstack endpoint create --region RegionOne object-store public http://controller:8080/v1/AUTH_%\(tenant_id\)s
openstack endpoint create --region RegionOne object-store internal http://controller:8080/v1/AUTH_%\(tenant_id\)s
openstack endpoint create --region RegionOne object-store admin http://controller:8080/v1
apt-get -y install swift swift-proxy python-swiftclient python-keystoneclient python-keystonemiddleware memcached
mkdir /etc/swift
curl -o /etc/swift/proxy-server.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/proxy-server.conf
sh pw_update.sh /etc/swift/proxy-server.conf
cd /etc/swift/

swift-ring-builder account.builder create 10 3 1
swift-ring-builder account.builder add --region 1 --zone 1 --ip 10.0.0.40 --port 6002 --device sdb --weight 100
swift-ring-builder account.builder add --region 1 --zone 2 --ip 10.0.0.40 --port 6002 --device sdc --weight 100
swift-ring-builder account.builder add --region 1 --zone 3 --ip 10.0.0.41 --port 6002 --device sdb --weight 100
swift-ring-builder account.builder add --region 1 --zone 4 --ip 10.0.0.41 --port 6002 --device sdc --weight 100
swift-ring-builder account.builder
swift-ring-builder account.builder rebalance

swift-ring-builder container.builder create 10 3 1
swift-ring-builder container.builder add --region 1 --zone 1 --ip 10.0.0.40 --port 6001 --device sdb --weight 100
swift-ring-builder container.builder add --region 1 --zone 2 --ip 10.0.0.40 --port 6001 --device sdc --weight 100
swift-ring-builder container.builder add --region 1 --zone 3 --ip 10.0.0.41 --port 6001 --device sdb --weight 100
swift-ring-builder container.builder add --region 1 --zone 4 --ip 10.0.0.41 --port 6001 --device sdc --weight 100
swift-ring-builder container.builder
swift-ring-builder container.builder rebalance

swift-ring-builder object.builder create 10 3 1
swift-ring-builder object.builder add --region 1 --zone 1 --ip 10.0.0.40 --port 6001 --device sdb --weight 100
swift-ring-builder object.builder add --region 1 --zone 2 --ip 10.0.0.40 --port 6001 --device sdc --weight 100
swift-ring-builder object.builder add --region 1 --zone 3 --ip 10.0.0.41 --port 6001 --device sdb --weight 100
swift-ring-builder object.builder add --region 1 --zone 4 --ip 10.0.0.41 --port 6001 --device sdc --weight 100
swift-ring-builder object.builder
swift-ring-builder object.builder rebalance

curl -o /etc/swift/swift.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/swift.conf

chown -R root:swift /etc/swift
service memcached restart
service swift-proxy restart

#Add the Orchestration service
mysql -uroot -p$ROOT_DB_PASS -e "CREATE DATABASE heat"
mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'localhost' IDENTIFIED BY '$HEAT_DBPASS'"
mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'%' IDENTIFIED BY '$HEAT_DBPASS'"

. $rootpath/admin-openrc.sh
openstack user create --domain default --password $HEAT_PASS heat
openstack role add --project service --user heat admin
openstack service create --name heat --description "Orchestration" orchestration
openstack service create --name heat-cfn --description "Orchestration"  cloudformation
openstack endpoint create --region RegionOne orchestration public http://controller:8004/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne orchestration internal http://controller:8004/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne orchestration admin http://controller:8004/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne cloudformation public http://controller:8000/v1
openstack endpoint create --region RegionOne cloudformation internal http://controller:8000/v1
openstack endpoint create --region RegionOne cloudformation admin http://controller:8000/v1
openstack domain create --description "Stack projects and users" heat
openstack user create --domain heat --password $HEAT_DOMAIN_PASS heat_domain_admin
openstack role add --domain heat --user heat_domain_admin admin
openstack role create heat_stack_owner
openstack role add --project demo --user demo heat_stack_owner
openstack role create heat_stack_user
apt-get -y install heat-api heat-api-cfn heat-engine python-heatclient

curl -o /etc/heat/heat.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/heat.conf
sh pw_update.sh /etc/heat/heat.conf
su -s /bin/sh -c "heat-manage db_sync" heat
service heat-api restart
service heat-api-cfn restart
service heat-engine restart
rm -f /var/lib/heat/heat.sqlite
