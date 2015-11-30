#!/bin/bash
sleep 1
repo=https://raw.githubusercontent.com/mustafatoraman/openstack/master/master
rm -rf /root/openstacklab.sh
wget -O /root/openstacklab.sh  $repo/openstacklab.sh  2>&1
chmod +x /root/openstacklab.sh
echo "Update completed."
sleep 1
openstacklab
