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
printf "ADMIN_TOKEN               $ADMIN_TOKEN\n"
printf "ROOT_DB_PASS              $ROOT_DB_PASS\n"
printf "ADMIN_PASS                $ADMIN_PASS\n"
printf "CEILOMETER_DBPASS         $CEILOMETER_DBPASS\n"
printf "CEILOMETER_PASS           $CEILOMETER_PASS\n"
printf "CINDER_DBPASS             $CINDER_DBPASS\n"
printf "CINDER_PASS               $CINDER_PASS\n"
printf "DASH_DBPASS               $DASH_DBPASS\n"
printf "DEMO_PASS                 $DEMO_PASS\n"
printf "GLANCE_DBPASS             $GLANCE_DBPASS\n"
printf "GLANCE_PASS               $GLANCE_PASS\n"
printf "HEAT_DBPASS               $HEAT_DBPASS\n"
printf "HEAT_DOMAIN_PASS          $HEAT_DOMAIN_PASS\n"
printf "HEAT_PASS                 $HEAT_PASS\n"
printf "KEYSTONE_DBPASS           $KEYSTONE_DBPASS\n"
printf "NEUTRON_DBPASS            $NEUTRON_DBPASS\n"
printf "NEUTRON_PASS              $NEUTRON_PASS\n"
printf "NOVA_DBPASS               $NOVA_DBPASS\n"
printf "NOVA_PASS                 $NOVA_PASS\n"
printf "RABBIT_PASS               $RABBIT_PASS\n"
printf "SWIFT_PASS                $SWIFT_PASS\n"
printf "METADATA_SECRET           $METADATA_SECRET\n"
echo "------------------------------------------------------"

echo "Passwords saved at ${code}/root/passwords.sh${clear} for reference"

sleep 3 
