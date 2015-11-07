#download ntp
apt-get install chrony
curl -o /etc/chrony/chrony.conf \
https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/controller/chrony.conf
service chrony restart
#OpenStack packages
apt-get -y install software-properties-common
add-apt-repository -y cloud-archive:liberty
apt-get update && apt-get dist-upgrade
apt-get install python-openstackclient
#
