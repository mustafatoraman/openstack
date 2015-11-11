#!/bin/bash
cd

clear
read -r -p "1) Download and run password generator? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        echo "Starting..."
curl -o /root/pw.sh https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/pw.sh
sh pw.sh
rm -rf pw.sh
        ;;
    *)
        echo "Moving next step..."
        ;;
esac

 

clear
read -r -p "2) Download password updater? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        echo "Starting..."
curl -o /root/pw_update.sh https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/pw_update.sh
        ;;
    *)
        echo "Moving next step..."
        ;;
esac


clear
echo "Loading passwords..."
#Load passwords
rootpath=/root
. $rootpath/passwords.sh




clear
read -r -p "3) Download and configure NTP Service? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        echo "Starting..."
apt-get -y install chrony
curl -o /etc/chrony/chrony.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/chrony.conf
service chrony restart
        ;;
    *)
        echo "Moving next step..."
        ;;
esac







clear
read -r -p "4) Download and update OpenStack Packages? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        echo "Starting..."
apt-get -y install software-properties-common
add-apt-repository -y cloud-archive:liberty
apt-get -y update && apt-get -y dist-upgrade
apt-get -y install python-openstackclient
sleep 3
clear
read -r -p " New kernel installed!!! Please reboot before moving to step 5? (Required) [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        echo "Rebooting..."
reboot
        ;;
    *)
        echo "Moving next step..."
        ;;
esac

        ;;
    *)
        echo "Moving next step..."
        ;;
esac

clear
read -r -p "5) Download and install MySQL Server? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        echo "Starting..."
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
        ;;
    *)
        echo "Moving next step..."
        ;;
esac


clear
read -r -p "6) Download and install NoSQL Server? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        echo "Starting..."
apt-get -y install mongodb-server mongodb-clients python-pymongo
curl -o /root/mongodb.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/mongodb.conf
service mongodb restart
        ;;
    *)
        echo "Moving next step..."
        ;;
esac


clear
read -r -p "7) Download and install RabbitMQ? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        echo "Starting..."
apt-get -y install rabbitmq-server
rabbitmqctl add_user openstack $RABBIT_PASS
rabbitmqctl set_permissions openstack ".*" ".*" ".*"
        ;;
    *)
        echo "Moving next step..."
        ;;
esac


clear
read -r -p "8) Download and install Keystone (Identity service)? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        echo "Starting..."
mysql -uroot -p$ROOT_DB_PASS -e "CREATE DATABASE keystone"
mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$KEYSTONE_DBPASS'"
mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$KEYSTONE_DBPASS'"
echo "manual" > /etc/init/keystone.override
apt-get -y install keystone apache2 libapache2-mod-wsgi memcached python-memcache
curl -o /etc/keystone/keystone.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/keystone.conf
sh pw_update.sh /etc/keystone/keystone.conf
su -s /bin/sh -c "keystone-manage db_sync" keystone
        ;;
    *)
        echo "Moving next step..."
        ;;
esac


clear
read -r -p "9) Download and configure Apache2 ? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        echo "Starting..."
curl -o /etc/apache2/apache2.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/apache2.conf
curl -o /etc/apache2/sites-available/wsgi-keystone.conf https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/wsgi-keystone.conf
ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled
service apache2 restart
rm -f /var/lib/keystone/keystone.db
        ;;
    *)
        echo "Moving next step..."
        ;;
esac


clear
read -r -p "10) Create the service entity and API endpoints? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        echo "Starting..."
rootpath=/root
. $rootpath/passwords.sh
export OS_TOKEN=$ADMIN_TOKEN
export OS_URL=http://controller:35357/v3
export OS_IDENTITY_API_VERSION=3
openstack service create --name keystone --description "OpenStack Identity" identity
openstack endpoint create --region RegionOne identity public http://controller:5000/v2.0
openstack endpoint create --region RegionOne identity internal http://controller:5000/v2.0
openstack endpoint create --region RegionOne identity admin http://controller:35357/v2.0
        ;;
    *)
        echo "Moving next step..."
        ;;
esac


clear
read -r -p "11) Create projects, users, and roles? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        echo "Starting..."
openstack project create --domain default --description "Admin Project" admin
openstack user create --domain default --password $ADMIN_PASS admin
openstack role create admin
openstack role add --project admin --user admin admin
openstack project create --domain default --description "Service Project" service
openstack project create --domain default --description "Demo Project" demo
openstack user create --domain default --password $DEMO_PASS demo
openstack role create user
openstack role add --project demo --user demo user
sed -i 's/token_auth admin_token_auth/token_auth/g' /etc/keystone/keystone-paste.ini
unset OS_TOKEN OS_URL
openstack --os-auth-url http://controller:35357/v3 --os-project-domain-id default --os-user-domain-id default --os-project-name admin --os-username admin --os-password $ADMIN_PASS token issue
openstack --os-auth-url http://controller:5000/v3 --os-project-domain-id default --os-user-domain-id default --os-project-name demo --os-username demo --os-password $DEMO_PASS token issue
        ;;
    *)
        echo "Moving next step..."
        ;;
esac



clear
read -r -p "12) Create OpenStack client environment scripts? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        echo "Starting..."
curl -o /root/admin-openrc.sh https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/admin-openrc.sh
curl -o /root/demo-openrc.sh https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/demo-openrc.sh
sh pw_update.sh /root/admin-openrc.sh
sh pw_update.sh /root/demo-openrc.sh
. $rootpath/admin-openrc.sh
openstack token issue
        ;;
    *)
        echo "Moving next step..."
        ;;
esac


clear
read -r -p "13) Download and configure Glance? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        echo "Starting..."
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
        ;;
    *)
        echo "Moving next step..."
        ;;
esac



clear
read -r -p "14) Download and configure Nova? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        echo "Starting..."
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
        ;;
    *)
        echo "Moving next step..."
        ;;
esac



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

        ;;
    *)
        echo "Moving next step..."
        ;;
esac



clear
read -r -p "16) Download and configure Horizon? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        echo "Starting..."
apt-get -y install openstack-dashboard
curl -o /etc/openstack-dashboard/local_settings.py https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/local_settings.py
apt-get -y remove --auto-remove openstack-dashboard-ubuntu-theme
service apache2 reload
        ;;
    *)
        echo "Moving next step..."
        ;;
esac


clear
read -r -p "17) Download and configure Cinder? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        echo "Starting..."
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
/etc/init.d/nova-api restart
/etc/init.d/cinder-scheduler restart
/etc/init.d/cinder-api restart
rm -f /var/lib/cinder/cinder.sqlite
        ;;
    *)
        echo "Moving next step..."
        ;;
esac



clear
read -r -p "18) Download and configure Swift? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        echo "Starting..."
rootpath=/root
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
/etc/init.d/memcached restart
/etc/init.d/swift-proxy restart
        ;;
    *)
        echo "Moving next step..."
        ;;
esac




clear
read -r -p "19) Download and configure Heat? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        echo "Starting..."
mysql -uroot -p$ROOT_DB_PASS -e "CREATE DATABASE heat"
mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'localhost' IDENTIFIED BY '$HEAT_DBPASS'"
mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'%' IDENTIFIED BY '$HEAT_DBPASS'"
rootpath=/root
. $rootpath/passwords.sh
. $rootpath/admin-openrc.sh
sleep 10
openstack user create --domain default --password $HEAT_PASS heat
sleep 5
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
/etc/init.d/heat-api restart
/etc/init.d/heat-api-cfn restart
/etc/init.d/heat-engine restart
rm -f /var/lib/heat/heat.sqlite
        ;;
    *)
        echo "Moving next step..."
        ;;
esac
