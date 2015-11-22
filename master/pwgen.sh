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
echo "Passwords saved at /root/passwords.sh for reference"
sleep 3 
