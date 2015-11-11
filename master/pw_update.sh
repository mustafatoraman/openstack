#!/bin/bash

rootpath=/root
. $rootpath/passwords.sh

sed -i -e "s/ADMIN_TOKEN/$ADMIN_TOKEN/g"  $1
sed -i -e "s/ROOT_DB_PASS/$ROOT_DB_PASS/g"  $1
sed -i -e "s/ADMIN_PASS/$ADMIN_PASS/g"  $1
sed -i -e "s/CEILOMETER_DBPASS/$CEILOMETER_DBPASS/g"  $1
sed -i -e "s/CEILOMETER_PASS/$CEILOMETER_PASS/g"  $1
sed -i -e "s/CINDER_DBPASS/$CINDER_DBPASS/g"  $1
sed -i -e "s/CINDER_PASS/$CINDER_PASS/g"  $1
sed -i -e "s/DASH_DBPASS/$DASH_DBPASS/g"  $1
sed -i -e "s/DEMO_PASS/$DEMO_PASS/g"  $1
sed -i -e "s/GLANCE_DBPASS/$GLANCE_DBPASS/g"  $1
sed -i -e "s/GLANCE_PASS/$GLANCE_PASS/g"  $1
sed -i -e "s/HEAT_DBPASS/$HEAT_DBPASS/g"  $1
sed -i -e "s/HEAT_DOMAIN_PASS/$HEAT_DOMAIN_PASS/g"  $1
sed -i -e "s/HEAT_PASS/$HEAT_PASS/g"  $1
sed -i -e "s/KEYSTONE_DBPASS/$KEYSTONE_DBPASS/g"  $1
sed -i -e "s/NEUTRON_DBPASS/$NEUTRON_DBPASS/g"  $1
sed -i -e "s/NEUTRON_PASS/$NEUTRON_PASS/g"  $1
sed -i -e "s/NOVA_DBPASS/$NOVA_DBPASS/g"  $1
sed -i -e "s/NOVA_PASS/$NOVA_PASS/g"  $1
sed -i -e "s/RABBIT_PASS/$RABBIT_PASS/g"  $1
sed -i -e "s/SWIFT_PASS/$SWIFT_PASS/g"  $1
sed -i -e "s/METADATA_SECRET/$METADATA_SECRET/g"  $1
echo "Variables updated."
