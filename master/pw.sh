#!/bin/bash
rootpath=/root

echo "Generating random passwords for setup"
sleep 1
cd
rm -rf passwords.sh
echo "#!/bin/bash" >> passwords.sh
echo "ADMIN_TOKEN=$(openssl rand -hex 10)" >> passwords.sh
echo "ROOT_DB_PASS=$(openssl rand -hex 6)" >> passwords.sh
echo "ADMIN_PASS=$(openssl rand -hex 6)" >> passwords.sh
echo "CEILOMETER_DBPASS=$(openssl rand -hex 6)" >> passwords.sh
echo "CEILOMETER_PASS=$(openssl rand -hex 6)" >> passwords.sh
echo "CINDER_DBPASS=$(openssl rand -hex 6)" >> passwords.sh
echo "CINDER_PASS=$(openssl rand -hex 6)" >> passwords.sh
echo "DASH_DBPASS=$(openssl rand -hex 6)" >> passwords.sh
echo "DEMO_PASS=$(openssl rand -hex 6)" >> passwords.sh
echo "GLANCE_DBPASS=$(openssl rand -hex 6)" >> passwords.sh
echo "GLANCE_PASS=$(openssl rand -hex 6)" >> passwords.sh
echo "HEAT_DBPASS=$(openssl rand -hex 6)" >> passwords.sh
echo "HEAT_DOMAIN_PASS=$(openssl rand -hex 6)" >> passwords.sh
echo "HEAT_PASS=$(openssl rand -hex 6)" >> passwords.sh
echo "KEYSTONE_DBPASS=$(openssl rand -hex 6)" >> passwords.sh
echo "NEUTRON_DBPASS=$(openssl rand -hex 6)" >> passwords.sh
echo "NEUTRON_PASS=$(openssl rand -hex 6)" >> passwords.sh
echo "NOVA_DBPASS=$(openssl rand -hex 6)" >> passwords.sh
echo "NOVA_PASS=$(openssl rand -hex 6)" >> passwords.sh
echo "RABBIT_PASS=$(openssl rand -hex 6)" >> passwords.sh
echo "SWIFT_PASS=$(openssl rand -hex 6)" >> passwords.sh
echo "METADATA_SECRET=$(openssl rand -hex 10)" >> passwords.sh


. $rootpath/passwords.sh

echo "------------------------------------------------------"
printf "ADMIN_TOKEN\t\t\t$ADMIN_TOKEN\n"
printf "ROOT_DB_PASS\t\t\t$ROOT_DB_PASS\n"
printf "ADMIN_PASS\t\t\t$ADMIN_PASS\n"
printf "CEILOMETER_DBPASS\t\t$CEILOMETER_DBPASS\n"
printf "CEILOMETER_PASS\t\t\t$CEILOMETER_PASS\n"
printf "CINDER_DBPASS\t\t\t$CINDER_DBPASS\n"
printf "CINDER_PASS\t\t\t$CINDER_PASS\n"
printf "DASH_DBPASS\t\t\t$DASH_DBPASS\n"
printf "DEMO_PASS\t\t\t$DEMO_PASS\n"
printf "GLANCE_DBPASS\t\t\t$GLANCE_DBPASS\n"
printf "GLANCE_PASS\t\t\t$GLANCE_PASS\n"
printf "HEAT_DBPASS\t\t\t$HEAT_DBPASS\n"
printf "HEAT_DOMAIN_PASS\t\t$HEAT_DOMAIN_PASS\n"
printf "HEAT_PASS\t\t\t$HEAT_PASS\n"
printf "KEYSTONE_DBPASS\t\t\t$KEYSTONE_DBPASS\n"
printf "NEUTRON_DBPASS\t\t\t$NEUTRON_DBPASS\n"
printf "NEUTRON_PASS\t\t\t$NEUTRON_PASS\n"
printf "NOVA_DBPASS\t\t\t$NOVA_DBPASS\n"
printf "NOVA_PASS\t\t\t$NOVA_PASS\n"
printf "RABBIT_PASS\t\t\t$RABBIT_PASS\n"
printf "SWIFT_PASS\t\t\t$SWIFT_PASS\n"
printf "METADATA_SECRET\t\t\t$METADATA_SECRET\n"
echo "------------------------------------------------------"

echo "Passwords saved at /root/passwords.sh for reference"

sleep 3 
