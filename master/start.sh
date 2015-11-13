#!/bin/bash

RED='\033[0;41;30m'
STD='\033[0;0;39m'
repo=https://raw.githubusercontent.com/mustafatoraman/openstack/master/master

 
pause(){
  read -p "Press [Enter] key to continue..." fackEnterKey
}
 
controller(){
echo "Controller Node selected."
sleep 1
hostname controller
echo "Downloading initial files..."
curl -o /etc/network/interfaces $repo/controller/interfaces
curl -o /etc/hostname $repo/controller/hostname
curl -o /etc/hosts $repo/controller/hosts
curl -o /root/install.sh $repo/controller/install.sh
rm -rf start.sh
echo "Initial setup completed."
sleep 1
echo "After restart you can use 10.0.10.10 IP address to connect back to controller node."
sleep 1
echo "To start actual installation , use 'sh install.sh' command."
sleep 1
echo "Server rebooting in 3 seconds..."
sleep 3
exit 0
#reboot
}
 
compute1(){
echo "Compute1 Node selected."
sleep 1
hostname compute1
echo "Downloading initial files..."
curl -o /etc/network/interfaces $repo/compute1/interfaces
curl -o /etc/hostname $repo/compute1/hostname
curl -o /etc/hosts $repo/compute1/hosts
curl -o /root/install.sh $repo/compute1/install.sh
rm -rf start.sh
echo "Initial setup completed."
sleep 1
echo "After restart you can use 10.0.10.20 IP address to connect back to compute1 node."
sleep 1
echo "To start actual installation , use 'sh install.sh' command."
sleep 1
echo "Server rebooting in 3 seconds..."
sleep 3
exit 0
#reboot
}

compute2(){
echo "Compute2 Node selected."
sleep 1
hostname compute2
echo "Downloading initial files..."
curl -o /etc/network/interfaces $repo/compute2/interfaces
curl -o /etc/hostname $repo/compute2/hostname
curl -o /etc/hosts $repo/compute2/hosts
curl -o /root/install.sh $repo/compute2/install.sh
rm -rf start.sh
echo "Initial setup completed."
sleep 1
echo "After restart you can use 10.0.10.21 IP address to connect back to compute2 node."
sleep 1
echo "To start actual installation , use 'sh install.sh' command."
sleep 1
echo "Server rebooting in 3 seconds..."
sleep 3
exit 0
#reboot
}

block1(){
echo "Block1 Node selected."
sleep 1
hostname block1
echo "Downloading initial files..."
curl -o /etc/network/interfaces $repo/block1/interfaces
curl -o /etc/hostname $repo/block1/hostname
curl -o /etc/hosts $repo/block1/hosts
curl -o /root/install.sh $repo/block1/install.sh
rm -rf start.sh
echo "Initial setup completed."
sleep 1
echo "After restart you can use 10.0.10.30 IP address to connect back to block1 node."
sleep 1
echo "To start actual installation , use 'sh install.sh' command."
sleep 1
echo "Server rebooting in 3 seconds..."
sleep 3
exit 0
#reboot
}

object1(){
echo "Object1 Node selected."
sleep 1
hostname object1
echo "Downloading initial files..."
curl -o /etc/network/interfaces $repo/object1/interfaces
curl -o /etc/hostname $repo/object1/hostname
curl -o /etc/hosts $repo/object1/hosts
curl -o /root/install.sh $repo/object1/install.sh
rm -rf start.sh
echo "Initial setup completed."
sleep 1
echo "After restart you can use 10.0.10.40 IP address to connect back to object1 node."
sleep 1
echo "To start actual installation , use 'sh install.sh' command."
sleep 1
echo "Server rebooting in 3 seconds..."
sleep 3
exit 0
#reboot
}

object2(){
echo "Object2 Node selected."
sleep 1
hostname object2
echo "Downloading initial files..."
curl -o /etc/network/interfaces $repo/object2/interfaces
curl -o /etc/hostname $repo/object2/hostname
curl -o /etc/hosts $repo/object2/hosts
curl -o /root/install.sh $repo/object2/install.sh
rm -rf start.sh
echo "Initial setup completed."
sleep 1
echo "After restart you can use 10.0.10.41 IP address to connect back to object2 node."
sleep 1
echo "To start actual installation , use 'sh install.sh' command."
sleep 1
echo "Server rebooting in 3 seconds..."
sleep 3
exit 0
#reboot
}
 
show_menus() {
	clear
	echo "~~~~~~~~~~~~~~~~~~~~~"	
	echo " OpenStack Installer"
	echo "~~~~~~~~~~~~~~~~~~~~~"
	echo "1. Controller"
	echo "2. Compute1"
	echo "3. Compute2"
	echo "4. Block1"
	echo "5. Object1"
	echo "6. Object2"
	echo "7. Exit"
}

read_options(){
	local choice
	read -p "Enter choice [ 1 - 7] " choice
	case $choice in
		1) controller ;;
		2) compute1 ;;
		3) compute2 ;;
		4) block1 ;;
		5) object1 ;;
		6) object2 ;;
		7) exit 0;;
		*) echo -e "${RED}Error...${STD}" && sleep 2
	esac
}

trap '' SIGINT SIGQUIT SIGTSTP
 
while true
do
 
	show_menus
	read_options
done
