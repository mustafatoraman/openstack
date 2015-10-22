#!/bin/bash

cd
#Download and run password generator
wget -q https://raw.githubusercontent.com/mustafatoraman/openstack/master/pw_gen.sh -O /root/pw_gen.sh
sh pw_gen.sh

#Load passwords
rootpath=/root
. $rootpath/passwords.sh

echo "Starting setup for controller"
sleep 1
echo "Configuring public interface (eth1)"
sleep 1
wget -q https://raw.githubusercontent.com/mustafatoraman/openstack/master/controller/interfaces -O /etc/network/interfaces
echo "Configuring hosts file"
sleep 1
wget -q https://raw.githubusercontent.com/mustafatoraman/openstack/master/controller/hosts -O /etc/hosts


echo "Configuring Network Time Protocol"
sleep 1
apt-get -y install chrony
wget -q https://raw.githubusercontent.com/mustafatoraman/openstack/master/controller/chrony.conf -O /etc/chrony/chrony.conf
echo "Reloading Chrony"
sleep 1
service chrony restart

echo "Enabling the OpenStack repository"
sleep 1
apt-get -y install software-properties-common
add-apt-repository -y cloud-archive:liberty
echo "Installing the OpenStack client"
sleep 1
apt-get -y install python-openstackclient
echo "Finalizing the installation"
sleep 1
apt-get -y update && apt-get -y dist-upgrade


echo "Installing and configuring the database server"
sleep 1

rootpath=/root
. $rootpath/passwords.sh
echo mariadb-server-5.5 mysql-server/root_password password $ROOT_DB_PASS | debconf-set-selections
echo mariadb-server-5.5 mysql-server/root_password_again password $ROOT_DB_PASS | debconf-set-selections
apt-get -y install mariadb-server python-pymysql

#save new config to bind 10.0.0.10 
wget -q https://raw.githubusercontent.com/mustafatoraman/openstack/master/controller/mysqld_openstack.cnf -O /etc/mysql/conf.d/mysqld_openstack.cnf
service mysql restart

#secure db
apt-get -y install expect
wget -q https://raw.githubusercontent.com/mustafatoraman/openstack/master/db_sec.sh -O /root/db_sec.sh
sh db_sec.sh


echo "Installing and configuring message queue service"
sleep 1
apt-get -y install rabbitmq-server
rabbitmqctl add_user openstack $RABBIT_PASS
rabbitmqctl set_permissions openstack ".*" ".*" ".*"


echo "Installing and configuring OpenStack Identity"
sleep 1

#create db and keystone user
mysql -uroot -p$ROOT_DB_PASS -e "CREATE DATABASE keystone"
mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$KEYSTONE_DBPASS'"
mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$KEYSTONE_DBPASS'"

#Disable the keystone service from starting automatically after installation
echo "manual" > /etc/init/keystone.override

#Install the packages
apt-get -y install keystone apache2 libapache2-mod-wsgi memcached python-memcache

#Updating keystone.conf 
wget -q https://raw.githubusercontent.com/mustafatoraman/openstack/master/controller/keystone.conf -O /etc/keystone/keystone.conf
sed -i -e "s/ADMIN_TOKEN/$ADMIN_TOKEN/g" /etc/keystone/keystone.conf
sed -i -e "s/KEYSTONE_DBPASS/$KEYSTONE_DBPASS/g" /etc/keystone/keystone.conf

#Populate the Identity service database
su -s /bin/sh -c "keystone-manage db_sync" keystone

echo "Configuring the Apache HTTP server"
sleep 1

#Download sample apache2.conf and wsgi-keystone.conf
wget -q https://raw.githubusercontent.com/mustafatoraman/openstack/master/controller/apache2.conf -O /etc/apache2/apache2.conf
wget -q https://raw.githubusercontent.com/mustafatoraman/openstack/master/controller/wsgi-keystone.conf -O /etc/apache2/sites-available/wsgi-keystone.conf

#Enable the Identity service virtual hosts
ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled

#Restart the Apache HTTP server and remove old db
service apache2 restart
rm -f /var/lib/keystone/keystone.db


echo "Creating the service entity and API endpoints"
sleep 1

#Configure the authentication token
export OS_TOKEN=$ADMIN_TOKEN
#Configure the endpoint URL
export OS_URL=http://controller:35357/v3
#Configure the Identity API version
export OS_IDENTITY_API_VERSION=3

#Create the service entity for the Identity service
openstack service create --name keystone --description "OpenStack Identity" identity
#Create the Identity service API endpoints
openstack endpoint create --region RegionOne identity public http://controller:5000/v2.0
openstack endpoint create --region RegionOne identity internal http://controller:5000/v2.0
openstack endpoint create --region RegionOne identity admin http://controller:35357/v2.0


echo "Creating sample projects, users, and roles"
sleep 1

#Create the admin project
openstack project create --domain default --description "Admin Project" admin
#Create the admin user
openstack user create --domain default --password $ADMIN_PASS admin
#Create the admin role
openstack role create admin
#Add the admin role to the admin project and user
openstack role add --project admin --user admin admin
#Create the service project
openstack project create --domain default --description "Service Project" service
#Create the demo project
openstack project create --domain default --description "Demo Project" demo
#Create the demo user
openstack user create --domain default --password $DEMO_PASS demo
#Create the user role
openstack role create user
#Add the user role to the demo project and user
openstack role add --project demo --user demo user


echo "Verifying operation"
sleep 1

#Disable the temporary authentication token mechanism
sed -i 's/token_auth admin_token_auth/token_auth/g' /etc/keystone/keystone-paste.ini
#Unset the temporary OS_TOKEN and OS_URL environment variables
unset OS_TOKEN OS_URL
#As the admin user, request an authentication token
openstack --os-auth-url http://controller:35357/v3 --os-project-domain-id default --os-user-domain-id default --os-project-name admin --os-username admin --os-password $ADMIN_PASS token issue
#As the demo user, request an authentication token
openstack --os-auth-url http://controller:5000/v3 --os-project-domain-id default --os-user-domain-id default --os-project-name demo --os-username demo --os-password $DEMO_PASS token issue


echo "Create OpenStack client environment scripts"
sleep 1

#Download sample admin-openrc.sh and demo-openrc.sh scripts
wget -q https://raw.githubusercontent.com/mustafatoraman/openstack/master/controller/admin-openrc.sh -O /root/admin-openrc.sh
wget -q https://raw.githubusercontent.com/mustafatoraman/openstack/master/controller/demo-openrc.sh -O /root/demo-openrc.sh

#Update passwords
sed -i "s/ADMIN_PASS/$ADMIN_PASS/g" /root/admin-openrc.sh
sed -i "s/DEMO_PASS/$DEMO_PASS/g" /root/demo-openrc.sh

#Load the admin-openrc.sh file to populate environment variables
. $rootpath/admin-openrc.sh
#Request an authentication token
openstack token issue

echo "Adding the Image service"
sleep 1

#Create glance database and user
mysql -uroot -p$ROOT_DB_PASS -e "CREATE DATABASE glance"
mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '$GLANCE_DBPASS'"
mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '$GLANCE_DBPASS'"

#Source the admin credentials to gain access to admin-only CLI commands
. $rootpath/admin-openrc.sh
#Request an authentication token
openstack token issue

#Create the glance user to create the service credentials
openstack user create --password $GLANCE_PASS glance
#Add the admin role to the glance user and service project
openstack role add --project service --user glance admin

#Create the glance service entity
openstack service create --name glance --description "OpenStack Image service" image

#Create the Image service API endpoints
openstack endpoint create --region RegionOne image public http://controller:9292
openstack endpoint create --region RegionOne image internal http://controller:9292
openstack endpoint create --region RegionOne image admin http://controller:9292

echo "Install and configure components"
sleep 1

#Install the packages
apt-get -y install glance python-glanceclient

#Download sample glance-api.conf and glance-registry.conf config files
wget -q https://raw.githubusercontent.com/mustafatoraman/openstack/master/controller/glance-api.conf -O /etc/glance/glance-api.conf
wget -q https://raw.githubusercontent.com/mustafatoraman/openstack/master/controller/glance-registry.conf -O /etc/glance/glance-registry.conf

#Update passwords
sed -i "s/GLANCE_PASS/$GLANCE_PASS/g" /etc/glance/glance-api.conf
sed -i "s/GLANCE_PASS/$GLANCE_PASS/g" /etc/glance/glance-registry.conf
sed -i "s/GLANCE_DBPASS/$GLANCE_DBPASS/g" /etc/glance/glance-api.conf
sed -i "s/GLANCE_DBPASS/$GLANCE_DBPASS/g" /etc/glance/glance-registry.conf

#Populate the Image service database
su -s /bin/sh -c "glance-manage db_sync" glance

#Finalize installation
#Restart the Image service services:
service glance-registry restart
service glance-api restart

#Remove unnecessary database
rm -f /var/lib/glance/glance.sqlite

#Verify operation 
#Configure the Image service client to use API version 2.0 in each client environment script
echo "export OS_IMAGE_API_VERSION=2" | tee -a admin-openrc.sh demo-openrc.sh

#Source the admin credentials to gain access to admin-only CLI commands
. $rootpath/admin-openrc.sh

#Download the source Cirros image
wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img

#Upload the image to the Image service using the QCOW2 disk format, bare container format, and public visibility so all projects can access it
glance image-create --name "cirros" --file cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --container-format bare --visibility public --progress

#Confirm upload of the image and validate attributes
glance image-list




echo "Install and configure controller node"
sleep 1

#Create nova database and user
mysql -uroot -p$ROOT_DB_PASS -e "CREATE DATABASE nova"
mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON glance.* TO 'nova'@'localhost' IDENTIFIED BY '$NOVA_DBPASS'"
mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON glance.* TO 'nova'@'%' IDENTIFIED BY '$NOVA_DBPASS'"

#Source the admin credentials to gain access to admin-only CLI commands
. $rootpath/admin-openrc.sh

#Create the nova user
openstack user create --domain default --password $NOVA_PASS nova
#Add the admin role to the nova user
openstack role add --project service --user nova admin
#Create the nova service entity
openstack service create --name nova --description "OpenStack Compute" compute
#Create the Compute service API endpoints
openstack endpoint create --region RegionOne compute public http://controller:8774/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute internal http://controller:8774/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute admin http://controller:8774/v2/%\(tenant_id\)s

#Install and configure components
apt-get -y install nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient

#Download sample nova.conf config file
wget -q https://raw.githubusercontent.com/mustafatoraman/openstack/master/controller/nova.conf -O /etc/nova/nova.conf

#Update passwords
sed -i "s/NOVA_DBPASS/$NOVA_DBPASS/g" /etc/nova/nova.conf
sed -i "s/RABBIT_PASS/$RABBIT_PASS/g" /etc/nova/nova.conf
sed -i "s/NOVA_PASS/$NOVA_PASS/g" /etc/nova/nova.conf
sed -i "s/NEUTRON_PASS/$NEUTRON_PASS/g" /etc/nova/nova.conf
sed -i "s/ADMIN_TOKEN/$ADMIN_TOKEN/g" /etc/nova/nova.conf

#Populate the Compute database
su -s /bin/sh -c "nova-manage db sync" nova
