apt-get install chrony
/etc/chrony/chrony.conf
apt-get -y install software-properties-common
add-apt-repository -y cloud-archive:liberty
apt-get update && apt-get dist-upgrade
apt-get install python-openstackclient
