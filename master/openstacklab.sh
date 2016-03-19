#!/bin/bash
# OpenStackLab for Cloud Advisors - OpenStack Automation Script
# ----------------------------------------------------------------------------------------
# Author: Mustafa Toraman <mtoraman@us.ibm.com>
# Copyright: IBM Corporation - 2016
# ----------------------------------------------------------------------------------------
# Last updated 19 Mar 2016
# ----------------------------------------------------------------------------------------
version="v1.6.0"
repo=https://raw.githubusercontent.com/mustafatoraman/openstack/master/master
export NCURSES_NO_UTF8_ACS=1
# temp/trap ------------------------------------------------------------------------------

DIALOG=${DIALOG=dialog}
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
speedfile=`speedfile 2>/dev/null` || speedfile=/tmp/speed$$

trap "rm -f $tempfile && rm -f $speedfile" 0 1 2 5 15

# colors # -------------------------------------------------------------------------------

code="\Zb\Zr"
info="\Zb\Z1"
notice="\Zb\Z3"
bold="\Zb"
clear="\Zn"

# load_passwords -------------------------------------------------------------------------

load_passwords () {

rootpath=/root
. $rootpath/passwords

}

# speed_menu -----------------------------------------------------------------------------

speed_menu () {

	$DIALOG	--colors \
			--clear --title " Automated Step Speed Selection " \
			--default-item "5" \
			--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
        	--menu "\nPlease select one of the following option for delay (seconds) between each automated step.\n\n\
This option may help you to have enough time to review each step results or complete installation without delay.\n \n" 16 120 5 \
"1" "${bold}Very Fast${clear}      (1 second delay)" \
"3" "${bold}Fast${clear}           (3 seconds delay)" \
"5" "${bold}Normal${clear}         (5 seconds delay)" \
"7" "${bold}Slow${clear}           (7 seconds delay)" \
"10" "${bold}Very Slow${clear}      (10 seconds delay)" 2> $speedfile

	retval=$?
	speed_selection=`cat $speedfile`
	case $retval in
		0)
    		speed=$speed_selection
    		rm -rf $speedfile;;
  		1)
			;;
  		255)
    		echo "ESC pressed.";;
	esac
}

# pw_gen ---------------------------------------------------------------------------------

pw_gen () {

if [ -f /root/passwords ]; then

	dialog 	--colors \
			--ok-label "Continue" \
			--backtitle "OpenStackLab for Cloud Advisors - ${version}"\
			--msgbox  "Passwords file found, we will use existing passwords in ${bold}/root/passwords${clear} ." 5 120

else

	rootpath=/root
	cd
	echo "Generating random passwords for setup" 2>&1 |\
		dialog 	--title " Generating random passwords "\
				--backtitle "OpenStackLab for Cloud Advisors - ${version}"\
				--progressbox 40 120; sleep $speed

	echo "ADMIN_PASS=$(openssl rand -hex 4)"        >> passwords
	echo "DEMO_PASS=$(openssl rand -hex 4)"         >> passwords
	echo "ROOT_DB_PASS=$(openssl rand -hex 4)"      >> passwords
	echo "RABBIT_PASS=$(openssl rand -hex 4)"       >> passwords
	echo "KEYSTONE_DBPASS=$(openssl rand -hex 4)"   >> passwords
	echo "GLANCE_DBPASS=$(openssl rand -hex 4)"     >> passwords
	echo "GLANCE_PASS=$(openssl rand -hex 4)"       >> passwords
	echo "NOVA_DBPASS=$(openssl rand -hex 4)"       >> passwords
	echo "NOVA_PASS=$(openssl rand -hex 4)"         >> passwords
	echo "NEUTRON_DBPASS=$(openssl rand -hex 4)"    >> passwords
	echo "NEUTRON_PASS=$(openssl rand -hex 4)"      >> passwords
	echo "SWIFT_PASS=$(openssl rand -hex 4)"        >> passwords
	echo "CINDER_DBPASS=$(openssl rand -hex 4)"     >> passwords
	echo "CINDER_PASS=$(openssl rand -hex 4)"       >> passwords
	echo "HEAT_DBPASS=$(openssl rand -hex 4)"       >> passwords
	echo "HEAT_DOMAIN_PASS=$(openssl rand -hex 4)"  >> passwords
	echo "HEAT_PASS=$(openssl rand -hex 4)"         >> passwords
	echo "CEILOMETER_DBPASS=$(openssl rand -hex 4)" >> passwords
	echo "CEILOMETER_PASS=$(openssl rand -hex 4)"   >> passwords
	echo "DASH_DBPASS=$(openssl rand -hex 4)"       >> passwords
	echo "ADMIN_TOKEN=$(openssl rand -hex 6)"       >> passwords
	echo "METADATA_SECRET=$(openssl rand -hex 6)"   >> passwords
	echo "SWIFT_HASH_SUF=$(openssl rand -hex 6)"    >> passwords
	echo "SWIFT_HASH_PRE=$(openssl rand -hex 6)"    >> passwords

	echo "Passwords saved in /root/passwords for reference" 2>&1 | \
		dialog 	--title " Generating random passwords " \
				--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
				--progressbox 40 120; sleep $speed
fi }

# pw_update ------------------------------------------------------------------------------

pw_update () {

	load_passwords

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
	sed -i -e "s/SWIFT_HASH_PRE/$SWIFT_HASH_PRE/g"  $1
	sed -i -e "s/SWIFT_HASH_SUF/$SWIFT_HASH_SUF/g"  $1

}

# reboot_now -----------------------------------------------------------------------------

reboot_now () {

	hostonlyip=$(cat /etc/network/interfaces | grep address | sed -n '2p' | awk '{print $2}')

	$DIALOG --colors \
			--title " Reboot Required " --clear \
			--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
			--yes-label "Continue" \
			--no-label "Exit" \
        	--yesno "\n\
Your ${info}$(hostname)${clear} node setup completed.\n\n\
In order to complete installation , you have to reboot. You can connect back to your ${info}$(hostname)${clear} node with following commands via SSH protocol.\n\n\
${code}ssh root@$(hostname)${clear}\n\
or\n\
${code}ssh root@$hostonlyip${clear}" 13 120

		case $? in
  			0)
				sleep 1
				$DIALOG	--colors \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}"\
						--ok-label "Continue" \
						--yes-label "Reboot" \
						--no-label "Exit" \
						--yesno "Please confirm to reboot ${info}$(hostname)${clear} node." 5 120
					case $? in
  						0)
    						reboot;;
  						1)
							menu ;;
  						255)
   							echo "ESC pressed.";;
					esac
				clear;;
  			1)
				menu ;;
  			255)
    			echo "ESC pressed.";;
		esac
}

# wrong server ---------------------------------------------------------------------------


wrong_server () {

	dialog 	--colors \
			--title " Wrong Server! " \
			--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
			--ok-label "Continue" \
			--infobox " You are in wrong step. This is ${info}$(hostname) node${clear}! Returning to main menu..." 4 120 ; sleep $speed
	menu
}


# restart_apache2 ------------------------------------------------------------------------


restart_apache2 () {

/usr/bin/pgrep apache2

if [ $? -ne 0 ]
then
	service apache2 restart && sleep 3 
fi
}

# check_internet_access ------------------------------------------------------------------

check_internet_access () {

	wget -q -T 10 --spider http://ibm.com

	if [ $? -eq 0 ]; then
		sleep 0
	else
		dialog 	--colors \
				--title " Internet Access Failed! " \
				--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
				--infobox " The Internet connection appears as failed , please check your settings and retry again. " 4 120 ; sleep 5
		clear
		exit 0
	fi
}

# step_failed -----------------------------------------------------------------------------

step_failed () {

		dialog 	--colors \
				--title " Step Failed! " \
				--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
				--ok-label "Continue" \
				--msgbox "Step failed or unable to verify changes.\n\nPlease check your internet connectivity, update script and restart the same step from menu." 6 120
		exit 0
}

# 1.1 ------------------------------------------------------------------------------------


1.0 () {

	1.1

}

1.1 () {

	totalcore=$(echo $(grep -c ^processor /proc/cpuinfo) core\(s)\)
	totalram=$(grep MemTotal /proc/meminfo | awk '{print $2}' | xargs -I {} echo "scale=1; {}/1024^2" | bc | echo $(awk '{printf("%d\n",$1 + 0.5)}') GB)
	totaldisk=$(fdisk -l | grep " GB" |  cut -d "," -f1 | awk '{print $2,$3,$4}' )
	nics=$(ifconfig -s -a | grep eth | awk '{print $1}')

	$DIALOG --colors \
			--clear \
			--title " 1.1 - Example Architecture - Hardware Requirements " \
			--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
			--yes-label "Continue" \
			--no-label "Exit" \
        	--yesno "\n\
The example architecture requires ${bold}at least two nodes${clear} (hosts) to launch a \
basic virtual machine or instance. Optional services such as Block Storage and Object \
Storage require additional nodes.\n\n\
Please review the candidate server hardware specifications and make sure it's matching \
with minimum requirements of the node you want to install.\n\n\
${info}Candidate Node Hardware Specs${clear}\n\n\
Candidate Hostname      ${bold}$(hostname)${clear}\n\
CPU Cores               ${bold}$totalcore${clear}\n\
Total RAM               ${bold}$totalram${clear}\n\
Attached Harddisk(s)    ${bold}$totaldisk${clear}\n\
Active NIC(s)           ${bold}$nics${clear}\n\n\n\
${info}Example Architecture - Hardware Requirements${clear}\n\n\
${bold}Node Name   |  CPU Cores  |   RAM    |   Disk Configuration              |   NICs${clear}\n\
------------+-------------+----------+-----------------------------------+---------------\n\
controller *|   2 cores   |   6 GB   |   1 Disk - 50 GB                  |   3 NICs \n\
compute1   *|   2 cores   |   6 GB   |   1 Disk - 50 GB                  |   3 NICs \n\
compute2    |   2 cores   |   6 GB   |   1 Disk - 50 GB                  |   3 NICs \n\
block1      |   1 core    |   1 GB   |   2 Disks - 50 GB + 1 TB          |   2 NICs \n\
object1     |   1 core    |   1 GB   |   3 Disks - 50 GB + 1 TB + 1 TB   |   2 NICs \n\
object2     |   1 core    |   1 GB   |   3 Disks - 50 GB + 1 TB + 1 TB   |   2 NICs \n\n\n\
* Required for minimum installation\n" 35 120

	case $? in
  		0)
    		1.2 ;;
  		1)
			menu;;
  		255)
    		echo "ESC pressed.";;
	esac
}

# 1.2 ------------------------------------------------------------------------------------

1.2 () {
	$DIALOG --colors \
			--title " 1.2 - Example Architecture - Network Requirements " --clear \
			--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
			--yes-label "Continue" \
			--no-label "Exit" \
        	--yesno "\n\
As a part of multi-node OpenStack installation, each node require different network interface and settings. The example architecture uses ${bold}3 different network${clear} we created in VirtualBox.\n\n\
${info}Host-Only Network${clear}\nThis network required to access nodes from host computer to perform installation in VirtualBox environment. Different then NAT networks , Host-only network will give you direct access to nodes without any port-forwarding.\n\n\
${info}Management Network (NAT)${clear}\nThis network provides Internet access to all nodes for administrative purposes such as package installation, security updates, DNS, and NTP. Also, all nodes will communicate through management network for their own services.\n\n\
${info}Public Network (NAT)${clear}\nThis network provide Internet access to instances in your OpenStack environment. This network will be controlled by Neutron Service and has special configuration without static IP.\n\n\n\
${info}Example Architecture - Host Networking${clear}\n\n\
${bold}Node Name    |           eth0            |              eth1              |          eth2            ${clear}\n\
-------------+---------------------------+--------------------------------+--------------------------\n\
controller  *|  Host-only - 172.16.0.10  |  Management (NAT) - 10.0.0.10  |  Public (NAT) - No IP\n\
compute1    *|  Host-only - 172.16.0.20  |  Management (NAT) - 10.0.0.20  |  Public (NAT) - No IP\n\
compute2     |  Host-only - 172.16.0.21  |  Management (NAT) - 10.0.0.21  |  Public (NAT) - No IP\n\
block1       |  Host-only - 172.16.0.30  |  Management (NAT) - 10.0.0.30  |\n\
object1      |  Host-only - 172.16.0.40  |  Management (NAT) - 10.0.0.40  |\n\
object2      |  Host-only - 172.16.0.41  |  Management (NAT) - 10.0.0.41  |\n\n\
* Required for minimum installation\n" 35 120

	case $? in
  		0)
    		1.3 ;;
  		1)
			menu;;
  		255)
    		echo "ESC pressed.";;
	esac
}

# 1.3 ------------------------------------------------------------------------------------

1.3 () {

	$DIALOG	--clear --title " 1.3 - Prerequisites - Node Selection " \
			--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
        	--menu "Please select the node you want to start installation in this candidate server?" 13 120 6 \
        "controller"  "Master node for MySQL, RabbitMQ, Keystone, Glance and Neutron Services." \
        "compute1" "Required node for Nova Computing service." \
        "compute2" "Optional node for additional Nova computing service." \
        "block1" "Optional node for Cinder block storage service." \
        "object1" "Optional node for Swift object storage service. At least 2 nodes required if selected." \
        "object2" "Optional node for Swift object storage service. At least 2 nodes required if selected." 2> $tempfile

	retval=$?
	choice=`cat $tempfile`

	case $retval in

		0)
    		hostname $choice
    		1.4 ;;
  		1)
			menu;;
  		255)
    		echo "ESC pressed.";;
	esac
}

# 1.4 ------------------------------------------------------------------------------------

1.4 () {

	check_internet_access

	$DIALOG --colors \
			--title " 1.4 - Prerequisites - Node Networking Setup " --clear \
			--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
			--yes-label "Continue" \
			--no-label "Exit" \
        	--yesno "\n\
${info}$(hostname)${clear} node selected.\n\n\
Following files need custom changes in order to configure required network settings before installation.\n\n\
${bold}/etc/network/interfaces${clear}\n\
${bold}/etc/hostname${clear}\n\
${bold}/etc/hosts${clear}\n" 12 120

	case $? in
		0)
			sleep 1

			wget -O /etc/network/interfaces $repo/$(hostname)/interfaces 2>&1 | \
			dialog 	--title " Downloading preconfigured /etc/network/interfaces " \
					--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
					--progressbox 40 120; sleep $speed

			if ! grep -q "172.16" /etc/network/interfaces; then step_failed; fi

			wget -O /etc/hostname $repo/$(hostname)/hostname 2>&1 | \
			dialog 	--title " Downloading preconfigured /etc/hostname " \
					--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
					--progressbox 40 120; sleep $speed

			if grep -q "clone" /etc/hostname; then step_failed; fi

			wget -O /etc/hosts $repo/$(hostname)/hosts 2>&1 | \
			dialog 	--title " Downloading preconfigured /etc/hosts " \
					--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
					--progressbox 40 120; sleep $speed

			if ! grep -q "controller" /etc/hosts; then step_failed; fi

			dialog 	--ok-label "Continue" \
					--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
					--msgbox  "Node Networking Setup completed. " 5 120

			dialog  --clear\
					--exit-label Continue \
					--title " Review /etc/network/interfaces " \
					--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
					--textbox /etc/network/interfaces 40 120

			dialog  --clear\
					--exit-label Continue \
					--title " Review /etc/hostname " \
					--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
					--textbox /etc/hostname 40 120

			dialog  --clear\
					--exit-label Continue \
					--title " Review /etc/hosts " \
					--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
					--textbox /etc/hosts 40 120
    		1.5
			clear;;
		1)
			menu ;;
  		255)
    		echo "ESC pressed.";;
	esac
}

# 1.5 ------------------------------------------------------------------------------------

1.5 () {

	check_internet_access

	$DIALOG --colors \
			--yes-label "Continue" \
			--no-label "Exit" \
			--title " 1.5 - Prerequisites - Network Time Protocol (NTP) Setup " --clear \
			--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
       		--yesno "\n\
OpenStack require NTP Network Time Protocol to properly synchronize services among nodes.\n\n\
Steps to configure NTP service\n\n\
1) ${bold}Install Chrony packages${clear}\n\
2) ${bold}Download preconfigured /etc/chrony/chrony.conf configuration file${clear}\n\
3) ${bold}Restart the NTP service${clear}\n\n" 12 120

	case $? in
  		0)
			sleep 1

			apt-get -y install chrony 2>&1 | \
			dialog 	--title " Installing Chrony packages " \
					--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
					--progressbox 40 120; sleep $speed

			if ! apt-get -qq install chrony; then step_failed ; fi

			wget -O /etc/chrony/chrony.conf $repo/$(hostname)/chrony.conf 2>&1 | \
			dialog 	--title " Downloading preconfigured /etc/chrony/chrony.conf " \
					--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
					--progressbox 40 120; sleep $speed

			if ! grep -q "server" /etc/chrony/chrony.conf; then step_failed; fi

			dialog  --clear\
					--exit-label Continue \
					--title " Review /etc/chrony/chrony.conf " \
					--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
					--textbox /etc/chrony/chrony.conf 40 120

			service chrony restart 2>&1 | \
			dialog 	--title " Restarting the NTP service " \
					--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
					--progressbox 40 120; sleep $speed

			dialog 	--ok-label "Continue" \
					--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
					--msgbox  "NTP service setup completed. " 5 120

    		1.6 ;;
		1)
			menu ;;
  		255)
    		echo "ESC pressed.";;
	esac
}

# 1.6 ------------------------------------------------------------------------------------

1.6 () {

	check_internet_access

	$DIALOG --colors \
			--title " 1.6 - Prerequisites - OpenStack Packages " --clear \
			--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
			--yes-label "Continue" \
			--no-label "Exit" \
        	--yesno "\n\
Any OpenStack node must contain the latest versions of base installation packages available proceeding further. \n\n\
Steps to install OpenStack Packages\n\n\
1) ${bold}Enable the OpenStack repository${clear}\n\
2) ${bold}Upgrade the packages on host${clear}\n\
3) ${bold}Install the OpenStack client and additional necessary packages${clear}\n\n" 12 120

	case $? in
  		0)
			sleep 1

			( apt-get -y install software-properties-common && add-apt-repository -y cloud-archive:liberty )  2>&1 | \
			dialog 	--title " Enabling the OpenStack repository " \
					--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
					--progressbox 40 120; sleep $speed

			if ! apt-get -qq install software-properties-common; then step_failed ; fi

			unset UCF_FORCE_CONFFOLD
			export UCF_FORCE_CONFFNEW=YES
			ucf --purge /boot/grub/menu.lst

			export DEBIAN_FRONTEND=noninteractive
			( apt-get -y update && apt-get -o Dpkg::Options::="--force-confnew" --force-yes -fuy dist-upgrade ) 2>&1 | \
			dialog 	--title " Upgrading the packages on host " \
					--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
					--progressbox 40 120; sleep $speed

			apt-get -y install python-openstackclient arptables conntrack 2>&1 | \
			dialog 	--title " Installing the OpenStack client and related packages " \
					--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
					--progressbox 40 120; sleep $speed

			if ! apt-get -qq install python-openstackclient arptables conntrack; then step_failed ; fi

			dialog 	--ok-label "Continue" \
					--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
					--msgbox  "OpenStack Package installation completed " 5 120

  			1.7 ;;
 		1)
			menu ;;
 		255)
    		echo "ESC pressed.";;
	esac
}

# 1.7 ------------------------------------------------------------------------------------

1.7 () {

	hostonlyip=$(cat /etc/network/interfaces | grep address | sed -n '1p' | awk '{print $2}')

	$DIALOG --colors \
			--title " 1.7 - Prerequisites - Reboot to Apply Changes " --clear \
			--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
			--yes-label "Continue" \
			--no-label "Exit" \
        	--yesno "\n\
Your ${info}$(hostname)${clear} node prerequisites are completed.\n\n\
In order to continue OpenStackLab installation , you have to reboot this node to activate new network settings and any OS Kernel upgrade. You can connect back to your ${info}$(hostname)${clear} node with following commands via SSH protocol.\n\n\
${code}ssh root@$(hostname)${clear}\n\
or\n\
${code}ssh root@$hostonlyip${clear}\n\n\
After you connect back to your ${info}$(hostname)${clear} node , you can continue installation with following command.\n\n\
${code}openstacklab${clear}\n\n" 17 120

	case $? in
  		0)
			sleep 1

			$DIALOG	--colors \
					--ok-label "Continue" \
					--yes-label "Reboot" \
					--no-label "Exit" \
					--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
					--yesno   "Please confirm to reboot ${info}$(hostname)${clear} node." 5 120

			case $? in
  				0)
					reboot;;
  				1)
					menu ;;
  				255)
					echo "ESC pressed.";;
			esac
				clear;;
  		1)
			menu ;;
  		255)
    		echo "ESC pressed.";;
	esac
}

# 2.1 ------------------------------------------------------------------------------------

2.0 () {

	2.1

}

2.1 () {

	if [ "$(hostname)" = "controller" ]; then

		$DIALOG --colors \
			--clear \
			--title " 2.1 - Generate Passwords " \
			--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
			--yes-label "Continue" \
			--no-label "Exit" \
        	--yesno "\n\
To ease the installation process, this step generates secure passwords for node installations.\n\n\
The following table provides a list of services that require passwords and their associated references in the guide.\n\n\
${bold}ADMIN_PASS${clear}           Password of user admin\n\
${bold}DEMO_PASS${clear}            Password of user demo\n\
${bold}ROOT_DB_PASS${clear}         Root password for the database\n\
${bold}RABBIT_PASS${clear}          Password of user guest of RabbitMQ\n\
${bold}KEYSTONE_DBPASS${clear}      Database password of Identity service\n\
${bold}GLANCE_DBPASS${clear}        Database password for Image service\n\
${bold}GLANCE_PASS${clear}          Password of Image service user glance\n\
${bold}NOVA_DBPASS${clear}          Database password for Compute service\n\
${bold}NOVA_PASS${clear}            Password of Compute service user nova\n\
${bold}NEUTRON_DBPASS${clear}       Database password for the Networking service\n\
${bold}NEUTRON_PASS${clear}         Password of Networking service user neutron\n\
${bold}CINDER_DBPASS${clear}        Database password for the Block Storage service\n\
${bold}CINDER_PASS${clear}          Password of Block Storage service user cinder\n\
${bold}SWIFT_PASS${clear}           Password of Object Storage service user swift\n\
${bold}HEAT_DBPASS${clear}          Database password for the Orchestration service\n\
${bold}HEAT_DOMAIN_PASS${clear}     Password of Orchestration domain\n\
${bold}HEAT_PASS${clear}            Password of Orchestration service user heat\n\
${bold}CEILOMETER_DBPASS${clear}    Database password for the Telemetry service\n\
${bold}CEILOMETER_PASS${clear}      Password of Telemetry service user ceilometer\n\
${bold}DASH_DBPASS${clear}          Database password for the dashboard\n\
${bold}ADMIN_TOKEN${clear}          Administration token for setup\n\
${bold}METADATA_SECRET${clear}      Secret for the metadata proxy\n\
${bold}SWIFT_HASH_SUF${clear}       Hash path prefix for object storage service\n\
${bold}SWIFT_HASH_PRE${clear}       Suffix for object storage environment\n" 34 120

		case $? in
  			0)
				pw_gen
				show_passwords ;;
  			1)
				menu;;
  			255)
    			echo "ESC pressed.";;
			esac
	else
		wrong_server
	fi
}

# show_passwords -------------------------------------------------------------------------

show_passwords () {

	load_passwords

	$DIALOG --colors \
			--clear \
			--title " 2.1 - Generate Passwords " \
			--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
			--yes-label "Continue" \
			--no-label "Exit" \
        	--yesno "\n\
During installation installer will use following passwords and update configuration files.\n\n\
${bold}ADMIN_PASS${clear}           $ADMIN_PASS\n\
${bold}DEMO_PASS${clear}            $DEMO_PASS\n\
${bold}ROOT_DB_PASS${clear}         $ROOT_DB_PASS\n\
${bold}RABBIT_PASS${clear}          $RABBIT_PASS\n\
${bold}KEYSTONE_DBPASS${clear}      $KEYSTONE_DBPASS\n\
${bold}GLANCE_DBPASS${clear}        $GLANCE_DBPASS\n\
${bold}GLANCE_PASS${clear}          $GLANCE_PASS\n\
${bold}NOVA_DBPASS${clear}          $NOVA_DBPASS\n\
${bold}NOVA_PASS${clear}            $NOVA_PASS\n\
${bold}NEUTRON_DBPASS${clear}       $NEUTRON_DBPASS\n\
${bold}NEUTRON_PASS${clear}         $NEUTRON_PASS\n\
${bold}CINDER_DBPASS${clear}        $CINDER_DBPASS\n\
${bold}CINDER_PASS${clear}          $CINDER_PASS\n\
${bold}SWIFT_PASS${clear}           $SWIFT_PASS\n\
${bold}HEAT_DBPASS${clear}          $HEAT_DBPASS\n\
${bold}HEAT_DOMAIN_PASS${clear}     $HEAT_DOMAIN_PASS\n\
${bold}HEAT_PASS${clear}            $HEAT_PASS\n\
${bold}CEILOMETER_DBPASS${clear}    $CEILOMETER_DBPASS\n\
${bold}CEILOMETER_PASS${clear}      $CEILOMETER_PASS\n\
${bold}DASH_DBPASS${clear}          $DASH_DBPASS\n\
${bold}ADMIN_TOKEN${clear}          $ADMIN_TOKEN\n\
${bold}METADATA_SECRET${clear}      $METADATA_SECRET\n\
${bold}SWIFT_HASH_SUF${clear}       $SWIFT_HASH_SUF\n\
${bold}SWIFT_HASH_PRE${clear}       $SWIFT_HASH_PRE\n\n\
Anytime you can view passwords file with following command.\n\n\
${code}cat /root/passwords${clear}" 35 120

	case $? in
  		0)
			2.2	;;
  		1)
	 		menu ;;
  		255)
    		echo "ESC pressed.";;
		esac
}

# 2.2 ------------------------------------------------------------------------------------

2.2 () {

	check_internet_access

	if [ "$(hostname)" = "controller" ]; then

		$DIALOG --colors \
				--clear \
				--title " 2.2 - SQL Database " \
				--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
				--yes-label "Continue" \
				--no-label "Exit" \
        		--yesno "\n\
Most OpenStack services use an SQL database to store information. The database typically runs on the controller node.\n\n\
Steps to install SQL Database\n\n\
1) ${bold}Install the MariaDB packages${clear}\n\
2) ${bold}Download preconfigured /etc/mysql/conf.d/mysqld_openstack.cnf file${clear}\n\
3) ${bold}Restart the database service${clear}\n\
4) ${bold}Secure the database service${clear}\n" 14 120

		case $? in
			0)
				sleep 1

				dialog	--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--infobox "Installing the MariaDB packages..." 4 120 ; sleep $speed

				load_passwords

				echo mariadb-server-5.5 mysql-server/root_password password $ROOT_DB_PASS | debconf-set-selections
				echo mariadb-server-5.5 mysql-server/root_password_again password $ROOT_DB_PASS | debconf-set-selections
				apt-get -y install mariadb-server python-pymysql expect  > /dev/null 2>&1

				if ! apt-get -qq install mariadb-server python-pymysql expect; then step_failed ; fi

				wget -O /etc/mysql/conf.d/mysqld_openstack.cnf $repo/$(hostname)/mysqld_openstack.cnf 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/mysql/conf.d/mysqld_openstack.cnf " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "10.0.0.10" /etc/mysql/conf.d/mysqld_openstack.cnf; then step_failed; fi

				dialog  --clear\
						--exit-label Continue \
						--title " Review new /etc/mysql/conf.d/mysqld_openstack.cnf " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/mysql/conf.d/mysqld_openstack.cnf 40 120

				service mysql restart > /dev/null 2>&1
				echo "Restarting MariaDB database server mysqld..." 2>&1 | \
				dialog 	--title " Restarting the database service " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! pgrep mysql >/dev/null 2>&1; then echo "yes"; fi

				(wget -O /root/dbsec.sh $repo/$(hostname)/dbsec.sh && sh dbsec.sh) 2>&1 | \
				dialog 	--title " Securing the database service " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "bash" /root/dbsec.sh; then step_failed; fi

				dialog 	--ok-label "Continue" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--msgbox  "Database service setup completed. " 5 120

   				2.3 ;;
  			1)
				menu ;;
  			255)
    			echo "ESC pressed.";;
		esac
	else
		wrong_server
	fi
}

# 2.3 ------------------------------------------------------------------------------------

2.3 () {

	check_internet_access

	if [ "$(hostname)" = "controller" ]; then

		load_passwords

		$DIALOG --colors \
				--clear \
				--title " 2.3 - RabbitMQ - Message queue " \
				--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
				--yes-label "Continue" \
				--no-label "Exit" \
       			--yesno "\n\
OpenStack uses a message queue to coordinate operations and status information among \
services. The message queue service typically runs on the controller node.\n\n\
Steps to install RabbitMQ Message Queueu\n\n\
1) ${bold}Install the RabbitMQ packages${clear}\n\
2) ${bold}Add the OpenStack user${clear}\n\
3) ${bold}Permit configuration, write, and read access for the openstack user${clear}\n" 13 120

		case $? in
			0)
				sleep 1

				apt-get -y install rabbitmq-server 2>&1 | \
				dialog 	--title " Installing the RabbitMQ packages " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! apt-get -qq install rabbitmq-server; then step_failed ; fi

				rabbitmqctl add_user openstack $RABBIT_PASS 2>&1 | \
				dialog 	--title " Adding the openstack user " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				rabbitmqctl set_permissions openstack ".*" ".*" ".*" 2>&1 | \
				dialog 	--title " Permit configuration, write, and read access for the openstack user " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				dialog 	--ok-label "Continue" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--msgbox  "RabbitMQ message queue service setup completed. " 5 120

    			2.4 ;;
  			1)
				menu ;;
 			255)
    			echo "ESC pressed.";;
		esac
	else
		wrong_server
	fi
}

# 2.4 ------------------------------------------------------------------------------------

2.4 () {

	check_internet_access

	if [ "$(hostname)" = "controller" ]; then

		load_passwords

		$DIALOG --colors \
				--clear \
				--title " 2.4 - Keystone - Identity Service " \
				--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
				--yes-label "Continue" \
				--no-label "Exit" \
        		--yesno "\n\
This section describes how to install and configure the OpenStack Identity service, \
code-named keystone, on the controller node. For performance, this configuration deploys \
the Apache HTTP server to handle requests and Memcached to store tokens instead of an \
SQL database.\n\n\
Steps to install Keystone Identity Service\n\n\
1) ${bold}Create keystone database${clear}\n\
2) ${bold}Download and install the Keystone and Apache HTTP server packages${clear}\n\
3) ${bold}Download preconfigured /etc/keystone/keystone.conf keystone configuration file${clear}\n\
4) ${bold}Populate the Identity service database${clear}\n\
5) ${bold}Download preconfigured /etc/apache2/apache2.conf Apache configuration files${clear}\n\
6) ${bold}Download preconfigured /etc/apache2/sites-available/wsgi-keystone.conf Keystone HTTP configuration file${clear}\n\
7) ${bold}Restart Apache HTTP server${clear}\n" 18 120

		case $? in
  			0)
				sleep 1

				mysql -uroot -p$ROOT_DB_PASS -e "CREATE DATABASE keystone"
				mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$KEYSTONE_DBPASS'"
				mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$KEYSTONE_DBPASS'"
				echo "manual" > /etc/init/keystone.override

				dialog 	--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--infobox "Creating keystone database..." 4 120 ; sleep $speed

				apt-get -y install keystone apache2 libapache2-mod-wsgi memcached python-memcache 2>&1 | \
				dialog 	--title " Downloading Keystone and Apache packagages " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! apt-get -qq install keystone apache2 libapache2-mod-wsgi memcached python-memcache; then step_failed ; fi

				wget -O /etc/keystone/keystone.conf $repo/$(hostname)/keystone.conf 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/keystone/keystone.conf " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "controller" /etc/keystone/keystone.conf; then step_failed; fi

				dialog  --clear\
						--exit-label Continue \
						--title " Review new /etc/keystone/keystone.conf " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/keystone/keystone.conf 40 120

				pw_update /etc/keystone/keystone.conf

				su -s /bin/sh -c "keystone-manage db_sync" keystone 2>&1 | \
				dialog 	--title " Populate the Identity service database " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				wget -O /etc/apache2/apache2.conf $repo/$(hostname)/apache2.conf 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/apache2/apache2.conf Apache configuration " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "controller" /etc/apache2/apache2.conf; then step_failed; fi

				ln -s /etc/apache2/sites-available/wsgi-keystone.conf /etc/apache2/sites-enabled

				wget -O /etc/apache2/sites-available/wsgi-keystone.conf $repo/$(hostname)/wsgi-keystone.conf 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/apache2/sites-available/wsgi-keystone.conf Keystone HTTP configuration " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "keystone" /etc/apache2/sites-available/wsgi-keystone.conf; then step_failed; fi

				service apache2 restart 2>&1 | \
				dialog 	--title " Restarting Apache HTTP server " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! pgrep apache >/dev/null 2>&1; then step_failed; fi

				rm -f /var/lib/keystone/keystone.db

				dialog 	--ok-label "Continue" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--msgbox  "Keystone and Apache setup completed. " 5 120

				restart_apache2 > /dev/null 2>&1

    			2.5 ;;
  			1)
				menu ;;
  			255)
    			echo "ESC pressed.";;
		esac
	else
		wrong_server
	fi
}

# 2.5 ------------------------------------------------------------------------------------

2.5 () {

	check_internet_access

	if [ "$(hostname)" = "controller" ]; then

		load_passwords

		$DIALOG --colors \
			--clear \
			--title " 2.5 - Service entity and API endpoints " \
			--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
			--yes-label "Continue" \
			--no-label "Exit" \
        	--yesno "\n\
The Identity service provides a catalog of services and their locations. Each service \
that you add to your OpenStack environment requires a service entity and several API \
endpoints in the catalog.\n\n\
By default, the Identity service database contains no information to support conventional \
authentication and catalog services. We will use a the authentication token we created \
during password generate step and added into /etc/keystone/keystone.conf file.\n\n\
Steps to create Service entity and API endpoints\n\n\
1) ${bold}Configure the authentication token${clear}\n\
2) ${bold}Configure the endpoint URL${clear}\n\
3) ${bold}Configure the Identity API version${clear}\n\
4) ${bold}Create the service entity for the Identity service${clear}\n\
5) ${bold}Create the Identity service API endpoints${clear}\n" 20 120

		case $? in
  			0)
				sleep 1

				restart_apache2 > /dev/null 2>&1

				dialog 	--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--infobox "Configuring the authentication token, endpoint URL and Identity API version" 4 120 ; sleep $speed

				export OS_TOKEN=$ADMIN_TOKEN
				export OS_URL=http://controller:35357/v3
				export OS_IDENTITY_API_VERSION=3

				openstack service create --name keystone --description "OpenStack Identity" identity 2>&1 | \
				dialog 	--title " Creating the service entity for the Identity service " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne identity public http://controller:5000/v2.0 2>&1 | \
				dialog 	--title " Creating the Identity service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne identity internal http://controller:5000/v2.0 2>&1 | \
				dialog 	--title " Creating the Identity service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne identity admin http://controller:35357/v2.0 2>&1 | \
				dialog 	--title " Creating the Identity service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				dialog 	--ok-label "Continue" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--msgbox  "Service entity and API endpoints setup completed. " 5 120 


				restart_apache2 > /dev/null 2>&1

 				2.6 ;;
  			1)
				menu ;;
  			255)
    			echo "ESC pressed.";;
		esac
	else
		wrong_server
	fi
}

# 2.6 ------------------------------------------------------------------------------------

2.6 () {

	check_internet_access

	if [ "$(hostname)" = "controller" ]; then

		load_passwords

		$DIALOG --colors \
				--clear \
				--title " 2.6 - Create projects, users, and roles " \
				--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
				--yes-label "Continue" \
				--no-label "Exit" \
        		--yesno "\n\
The Identity service provides authentication services for each OpenStack service. The \
authentication service uses a combination of domains, projects (tenants), users, and \
roles.\n\n\
Steps to create projects, users, and roles\n\n\
1) ${bold}Create the admin project${clear}\n\
2) ${bold}Create the admin user${clear}\n\
3) ${bold}Create the admin role${clear}\n\
4) ${bold}Add the admin role to the admin project and user${clear}\n\
5) ${bold}Create the service project${clear}\n\
6) ${bold}Create the demo project${clear}\n\
7) ${bold}Create the demo user${clear}\n\
8) ${bold}Create the user role${clear}\n\
9) ${bold}Add the user role to the demo project and user${clear}\n" 20 120

		case $? in
  			0)
				sleep 1
				export OS_TOKEN=$ADMIN_TOKEN
				export OS_URL=http://controller:35357/v3
				export OS_IDENTITY_API_VERSION=3


				restart_apache2 > /dev/null 2>&1

				openstack project create --domain default --description "Admin Project" admin 2>&1 | \
				dialog 	--title " Creating the admin project " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack user create --domain default --password $ADMIN_PASS admin 2>&1 | \
				dialog 	--title " Creating the admin user " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack role create admin 2>&1 | \
				dialog 	--title " Creating the admin role  " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack role add --project admin --user admin admin 2>&1 | \
				dialog 	--title " Adding the admin role to the admin project and user  " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack project create --domain default --description "Service Project" service 2>&1 | \
				dialog 	--title " Creating the service project  " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack project create --domain default --description "Demo Project" demo 2>&1 | \
				dialog 	--title " Creating the demo project " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack user create --domain default --password $DEMO_PASS demo 2>&1 | \
				dialog 	--title " Creating the demo user " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack role create user 2>&1 | \
				dialog 	--title " Creating the user role " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack role add --project demo --user demo user 2>&1 | \
				dialog 	--title " Adding the user role to the demo project and user " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				sed -i 's/token_auth admin_token_auth/token_auth/g' /etc/keystone/keystone-paste.ini
				unset OS_TOKEN OS_URL

				openstack --os-auth-url http://controller:35357/v3 --os-project-domain-id default --os-user-domain-id default --os-project-name admin --os-username admin --os-password $ADMIN_PASS token issue > /dev/null 2>&1
				openstack --os-auth-url http://controller:5000/v3 --os-project-domain-id default --os-user-domain-id default --os-project-name demo --os-username demo --os-password $DEMO_PASS token issue > /dev/null 2>&1

				dialog 	--ok-label "Continue" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--msgbox  "Demo projects, users, and roles are created." 5 120

				restart_apache2 > /dev/null 2>&1

				2.7 ;;
  			1)
				menu ;;
  			255)
    			echo "ESC pressed.";;
		esac
	else
		wrong_server
	fi
}

# 2.7 ------------------------------------------------------------------------------------

2.7 () {

	check_internet_access

	if [ "$(hostname)" = "controller" ]; then

		load_passwords

		$DIALOG --colors \
			--clear \
			--title " 2.7 - OpenStack client environment scripts " \
			--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
			--yes-label "Continue" \
			--no-label "Exit" \
        	--yesno "\n\
To increase efficiency of client operations, OpenStack supports simple client environment \
scripts also known as OpenRC files. These scripts typically contain common options for \
all clients, but also support unique options.\n\n\
To run clients as a specific project and user, you can simply load the associated client \
environment script prior to running them. For example;\n\n\
Load the admin-openrc.sh file to populate environment variables with the location of the \
Identity service and the admin project and user credentials.\n\
${code}source admin-openrc.sh${clear}\n\n\
Request an authentication token\n\
${code}openstack token issue${clear}\n\n\
We will download and review two preconfigured client environment scripts to use during \
installation steps\n\
${code}/root/admin-openrc.sh${clear}\n\
${code}/root/demo-openrc.sh${clear}\n" 21 120

		case $? in
  			0)
				sleep 1

				unset OS_TOKEN
				unset OS_URL

				restart_apache2 > /dev/null 2>&1

				wget -O /root/admin-openrc.sh $repo/$(hostname)/admin-openrc.sh 2>&1 | \
				dialog 	--title " Downloading preconfigured /root/admin-openrc.sh " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "controller" /root/admin-openrc.sh; then step_failed; fi

				wget -O /root/demo-openrc.sh $repo/$(hostname)/demo-openrc.sh 2>&1 | \
				dialog 	--title " Downloading preconfigured /root/demo-openrc.sh " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "controller" /root/demo-openrc.sh; then step_failed; fi

				dialog  --clear\
						--exit-label Continue \
						--title " Review new /root/admin-openrc.sh file." \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /root/admin-openrc.sh 40 120

				dialog  --clear\
						--exit-label Continue \
						--title " Review new /root/demo-openrc.sh file." \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /root/demo-openrc.sh 40 120

				pw_update /root/admin-openrc.sh
				pw_update /root/demo-openrc.sh

				rootpath=/root
				. $rootpath/admin-openrc.sh
				openstack token issue > /dev/null 2>&1

				. $rootpath/admin-openrc.sh 2>&1 | \
				dialog 	--title " Load the admin-openrc.sh file to populate environment variables " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack token issue 2>&1 | \
				dialog 	--title " Requesting an authentication token for admin user " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				dialog 	--ok-label "Continue" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--msgbox  " OpenStack client environment scripts are created." 5 120

				restart_apache2 > /dev/null 2>&1

			    2.8 ;;
  			1)
				menu ;;
  			255)
    			echo "ESC pressed.";;
		esac
	else
		wrong_server
	fi
}

# 2.8 ------------------------------------------------------------------------------------

2.8 () {

	check_internet_access
	if [ "$(hostname)" = "controller" ]; then

		load_passwords

		$DIALOG --colors \
				--clear \
				--title " 2.8 - Glance - Image Service " \
				--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
				--yes-label "Continue" \
				--no-label "Exit" \
        		--yesno "\n\
The OpenStack Image service is central to Infrastructure-as-a-Service (IaaS). It accepts \
API requests for disk or server images, and image metadata from end users or OpenStack \
Compute components. It also supports the storage of disk or server images on various \
repository types, including OpenStack Object Storage.\n\n\
Steps to install Glance - Image Service\n\n\
1) ${bold}Create Glance database${clear}\n\
2) ${bold}Create the service credentials${clear}\n\
3) ${bold}Create the Image service API endpoints${clear}\n\
4) ${bold}Install and configure Glance components${clear}\n\
5) ${bold}Download preconfigured /etc/glance/glance-api.conf${clear}\n\
6) ${bold}Download preconfigured /etc/glance/glance-registry.conf${clear}\n\
7) ${bold}Populate the Image service database${clear}\n\
8) ${bold}Restart glance-registry and glance-api services${clear}\n\
9) ${bold}Download CirrOS linux source image and upload to the Image service ${clear}\n" 20 120

		case $? in
  			0)
				sleep 1

				restart_apache2 > /dev/null 2>&1

				mysql -uroot -p$ROOT_DB_PASS -e "CREATE DATABASE glance"
				mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '$GLANCE_DBPASS'"
				mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '$GLANCE_DBPASS'"

				dialog --infobox "Creating glance database..." 4 120 ; sleep $speed

				rootpath=/root
				. $rootpath/admin-openrc.sh
				openstack token issue > /dev/null 2>&1

				. $rootpath/admin-openrc.sh 2>&1 | \
				dialog 	--title " Loading the admin-openrc.sh file to to gain access to admin-only CLI commands " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack token issue 2>&1 | \
				dialog 	--title " Requesting an authentication token for admin user " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack user create --password $GLANCE_PASS glance 2>&1 | \
				dialog 	--title " Creating the glance user " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack role add --project service --user glance admin 2>&1 | \
				dialog 	--title " Adding the admin role to the glance user and service project " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack service create --name glance --description "OpenStack Image service" image 2>&1 | \
				dialog 	--title " Creating the glance service entity " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne image public http://controller:9292 2>&1 | \
				dialog 	--title " Create the Image service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne image internal http://controller:9292 2>&1 | \
				dialog 	--title " Create the Image service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne image admin http://controller:9292 2>&1 | \
				dialog 	--title " Create the Image service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				apt-get -y install glance python-glanceclient 2>&1 | \
				dialog 	--title " Installing the Glance packages " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! apt-get -qq install glance python-glanceclient; then step_failed ; fi

				wget -O /etc/glance/glance-api.conf $repo/$(hostname)/glance-api.conf 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/glance/glance-api.conf file " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "controller" /etc/glance/glance-api.conf; then step_failed; fi

				wget -O /etc/glance/glance-registry.conf $repo/$(hostname)/glance-registry.conf 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/glance/glance-registry.conf file " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "controller" /etc/glance/glance-registry.conf; then step_failed; fi

				dialog  --clear\
						--exit-label Continue \
						--title " Review new /etc/glance/glance-api.conf file." \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/glance/glance-api.conf 40 120

				dialog  --clear\
						--exit-label Continue \
						--title " Review new /etc/glance/glance-registry.conf file." \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/glance/glance-registry.conf 40 120

				pw_update /etc/glance/glance-api.conf
				pw_update /etc/glance/glance-registry.conf

				su -s /bin/sh -c "glance-manage db_sync" glance 2>&1 | \
				dialog 	--title " Populating the Image service database " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				( service glance-registry restart && service glance-api restart ) 2>&1 | \
				dialog 	--title " Restarting glance-registry and glance-api services" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! pgrep glance-registry >/dev/null 2>&1; then step_failed; fi
				if ! pgrep glance-api >/dev/null 2>&1; then step_failed; fi

				rm -f /var/lib/glance/glance.sqlite

				rm -rf cirros* >/dev/null 2>&1

				wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img 2>&1 | \
				dialog 	--title " Download the CirrOS source image "\
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				glance image-create --name "CirrOS" --file cirros-0.3.4-x86_64-disk.img --disk-format \
				qcow2 --container-format bare --visibility public --progress 2>&1 | \
				dialog 	--title " Upload the image to the Image service " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				glance image-list 2>&1 | \
				dialog 	--title " Confirming upload of the image and validate attributes " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				dialog 	--ok-label "Continue" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--msgbox  " Glance - Image Service setup completed." 5 120

				restart_apache2 > /dev/null 2>&1

 				2.9 ;;
  			1)
				menu ;;
  			255)
    			echo "ESC pressed.";;
		esac
	else
		wrong_server
	fi
}

# 2.9 ------------------------------------------------------------------------------------

2.9 () {

	check_internet_access

	if [ "$(hostname)" = "controller" ]; then

		load_passwords

		$DIALOG --colors \
				--clear \
				--title " 2.9 - Nova - Compute Service " \
				--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
				--yes-label "Continue" \
				--no-label "Exit" \
        		--yesno "\n\
The OpenStack Compute service is to host and manage cloud computing systems. OpenStack \
Compute is a major part of an Infrastructure-as-a-Service (IaaS) system.\n\n\
${info}This service require at least 1 individual nova node (compute1) !${clear}\n\n\
Steps to install Nova - Compute Service\n\n\
1) ${bold}Create Nova database${clear}\n\
2) ${bold}Create the service credentials${clear}\n\
3) ${bold}Create the Image service API endpoints${clear}\n\
4) ${bold}Install and configure Nova components${clear}\n\
5) ${bold}Download preconfigured /etc/nova/nova.conf${clear}\n\
6) ${bold}Populate the Compute service database${clear}\n\
7) ${bold}Restart nova services${clear}\n" 19 120

		case $? in
  			0)
				sleep 1

				restart_apache2 > /dev/null 2>&1

				rootpath=/root
				. $rootpath/admin-openrc.sh
				openstack token issue > /dev/null 2>&1

				mysql -uroot -p$ROOT_DB_PASS -e "CREATE DATABASE nova"
				mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$NOVA_DBPASS'"
				mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '$NOVA_DBPASS'"

				dialog 	--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--infobox "Creating nova database..." 4 120 ; sleep $speed

				. $rootpath/admin-openrc.sh 2>&1 | \
				dialog 	--title " Loading the admin-openrc.sh file to to gain access to admin-only CLI commands " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack token issue 2>&1 | \
				dialog 	--title " Requesting an authentication token for admin user " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack user create --domain default --password $NOVA_PASS nova 2>&1 | \
				dialog 	--title " Creating the nova user " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack role add --project service --user nova admin 2>&1 | \
				dialog 	--title " Adding the admin role to the nova user and service project " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack service create --name nova --description "OpenStack Compute" compute 2>&1 | \
				dialog 	--title " Creating the nova service entity " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne compute public http://controller:8774/v2/%\(tenant_id\)s 2>&1 | \
				dialog 	--title " Create the Nova service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne compute internal http://controller:8774/v2/%\(tenant_id\)s 2>&1 | \
				dialog 	--title " Create the Nova service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne compute admin http://controller:8774/v2/%\(tenant_id\)s 2>&1 | \
				dialog 	--title " Create the Nova service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				apt-get -y install nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient 2>&1 | \
				dialog 	--title " Installing the Nova packages " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! apt-get -qq install nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient; then step_failed ; fi

				wget -O /etc/nova/nova.conf $repo/$(hostname)/nova.conf 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/nova/nova.conf file " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "controller" /etc/nova/nova.conf; then step_failed; fi

				dialog  --clear\
						--exit-label Continue \
						--title " Review new /etc/nova/nova.conf file." \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/nova/nova.conf 40 120

				pw_update /etc/nova/nova.conf

				su -s /bin/sh -c "nova-manage db sync" nova 2>&1 | \
				dialog 	--title " Populating the Nova service database " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				( service nova-api restart && \
				service nova-cert restart && \
				service nova-consoleauth restart && \
				service nova-scheduler restart && \
				service nova-conductor restart && \
				service nova-novncproxy restart ) 2>&1 | \
				dialog 	--title " Restarting nova services" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! pgrep nova-api >/dev/null 2>&1; then step_failed; fi
				if ! pgrep nova-cert >/dev/null 2>&1; then step_failed; fi
				if ! pgrep nova-scheduler >/dev/null 2>&1; then step_failed; fi
				if ! pgrep nova-novncproxy >/dev/null 2>&1; then step_failed; fi

				rm -f /var/lib/nova/nova.sqlite

				dialog 	--ok-label "Continue" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--msgbox  " Nova - Compute Service setup completed." 5 120

				restart_apache2 > /dev/null 2>&1

  				2.10 ;;
  			1)
				menu ;;
  			255)
    			echo "ESC pressed.";;
		esac
	else
		wrong_server
	fi
}

# 2.10 -----------------------------------------------------------------------------------

2.10 () {

	check_internet_access

	if [ "$(hostname)" = "controller" ]; then

		load_passwords

		$DIALOG --colors \
				--clear \
				--title " 2.10 - Neutron - Networking Service " \
				--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
				--yes-label "Continue" \
				--no-label "Exit" \
        		--yesno "\n\
OpenStack Networking (neutron) manages all networking facets for the Virtual Networking \
Infrastructure (VNI) and the access layer aspects of the Physical Networking \
Infrastructure (PNI) in your OpenStack environment. OpenStack Networking enables \
tenants to create advanced virtual network topologies which may include services \
such as a firewall, a load balancer, and a virtual private network (VPN).\n\n\
${info}This service require Neutron Client installation in nova nodes !${clear}\n\n\
Steps to install Neutron - Networking Service\n\n\
1) ${bold}Create Neutron database${clear}\n\
2) ${bold}Create the service credentials${clear}\n\
3) ${bold}Create the Neutron service API endpoints${clear}\n\
4) ${bold}Install and configure Neutron components${clear}\n\
5) ${bold}Download preconfigured neutron configuration files${clear}\n\
6) ${bold}Populate the Neutron service database${clear}\n\
7) ${bold}Restart neutron services${clear}\n" 21 120

		case $? in
  			0)
				sleep 1

				restart_apache2 > /dev/null 2>&1

				rootpath=/root
				. $rootpath/admin-openrc.sh
				openstack token issue > /dev/null 2>&1


				mysql -uroot -p$ROOT_DB_PASS -e "CREATE DATABASE neutron"
				mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '$NEUTRON_DBPASS'"
				mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '$NEUTRON_DBPASS'"

				dialog 	--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--infobox "Creating neutron database..." 4 120 ; sleep $speed

				. $rootpath/admin-openrc.sh 2>&1 | \
				dialog 	--title " Loading the admin-openrc.sh file to to gain access to admin-only CLI commands " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack token issue 2>&1 | \
				dialog 	--title " Requesting an authentication token for admin user " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack user create --domain default --password $NEUTRON_PASS neutron 2>&1 | \
				dialog 	--title " Creating the neutron user " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack role add --project service --user neutron admin 2>&1 | \
				dialog 	--title " Adding the admin role to the neutron user and service project " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack service create --name neutron --description "OpenStack Networking" network 2>&1 | \
				dialog 	--title " Creating the neutron service entity " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne network public http://controller:9696 2>&1 | \
				dialog 	--title " Create the Neutron service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne network internal http://controller:9696 2>&1 | \
				dialog 	--title " Create the Neutron service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne network admin http://controller:9696 2>&1 | \
				dialog 	--title " Create the Neutron service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				apt-get -y install neutron-server neutron-plugin-ml2 neutron-plugin-linuxbridge-agent \
				neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent python-neutronclient 2>&1 | \
				dialog 	--title " Installing the Neutron packages " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! apt-get -qq install neutron-server neutron-plugin-ml2 neutron-plugin-linuxbridge-agent; then step_failed ; fi

				( wget -O /etc/neutron/neutron.conf $repo/$(hostname)/neutron.conf && \
				wget -O /etc/neutron/plugins/ml2/ml2_conf.ini $repo/$(hostname)/ml2_conf.ini && \
				wget -O /etc/neutron/plugins/ml2/linuxbridge_agent.ini $repo/$(hostname)/linuxbridge_agent.ini && \
				wget -O /etc/neutron/l3_agent.ini $repo/$(hostname)/l3_agent.ini && \
				wget -O /etc/neutron/dhcp_agent.ini $repo/$(hostname)/dhcp_agent.ini && \
				wget -O /etc/neutron/dnsmasq-neutron.conf $repo/$(hostname)/dnsmasq-neutron.conf && \
				wget -O /etc/neutron/metadata_agent.ini $repo/$(hostname)/metadata_agent.ini ) 2>&1 | \
				dialog 	--title " Downloading preconfigured neutron configuration files " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "controller" /etc/neutron/neutron.conf; then step_failed; fi
				if ! grep -q "vxlan" /etc/neutron/plugins/ml2/ml2_conf.ini; then step_failed; fi
				if ! grep -q "linux_bridge" /etc/neutron/plugins/ml2/linuxbridge_agent.ini; then step_failed; fi
				if ! grep -q "BridgeInterfaceDriver" /etc/neutron/l3_agent.ini; then step_failed; fi
				if ! grep -q "BridgeInterfaceDriver" /etc/neutron/dhcp_agent.ini; then step_failed; fi
				if ! grep -q "dhcp" /etc/neutron/dnsmasq-neutron.conf; then step_failed; fi
				if ! grep -q "controller" /etc/neutron/metadata_agent.ini; then step_failed; fi

				dialog  --clear\
						--exit-label Continue \
						--title " Review new /etc/neutron/neutron.conf file." \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/neutron/neutron.conf 40 120

				dialog  --clear\
						--exit-label Continue \
						--title " Review new /etc/neutron/plugins/ml2/ml2_conf.ini file." \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/neutron/plugins/ml2/ml2_conf.ini 40 120

				dialog  --clear\
						--exit-label Continue \
						--title " Review new /etc/neutron/plugins/ml2/linuxbridge_agent.ini file." \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/neutron/plugins/ml2/linuxbridge_agent.ini 40 120

				dialog  --clear\
						--exit-label Continue \
						--title " Review new /etc/neutron/l3_agent.ini file." \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/neutron/l3_agent.ini 40 120

				dialog  --clear\
						--exit-label Continue \
						--title " Review new /etc/neutron/dhcp_agent.ini file." \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/neutron/dhcp_agent.ini 40 120

				dialog  --clear\
						--exit-label Continue \
						--title " Review new /etc/neutron/dnsmasq-neutron.conf file." \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/neutron/dnsmasq-neutron.conf 40 120

				dialog  --clear\
						--exit-label Continue \
						--title " Review new  /etc/neutron/metadata_agent.ini file." \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox  /etc/neutron/metadata_agent.ini 40 120

				pw_update /etc/neutron/neutron.conf
				pw_update /etc/neutron/plugins/ml2/ml2_conf.ini
				pw_update /etc/neutron/plugins/ml2/linuxbridge_agent.ini
				pw_update /etc/neutron/l3_agent.ini
				pw_update /etc/neutron/dhcp_agent.ini
				pw_update /etc/neutron/dnsmasq-neutron.conf
				pw_update /etc/neutron/metadata_agent.ini

				su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron 2>&1 | \
				dialog 	--title " Populating the Neutron service database " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				( service nova-api restart && \
				service neutron-server restart && \
				service neutron-plugin-linuxbridge-agent restart && \
				service neutron-dhcp-agent restart && \
				service neutron-metadata-agent restart && \
				service neutron-l3-agent restart && \
				echo "Please wait for neutron services to sync up..." ) 2>&1 | \
				dialog 	--title " Restarting Neutron services" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				until cat /var/log/neutron/neutron-metadata-agent.log | grep -m 1 "run outlasted interval"; do : ; done > /dev/null 2>&1
				until cat /var/log/neutron/neutron-plugin-linuxbridge-agent.log | grep -m 1 "run outlasted interval"; do : ; done > /dev/null 2>&1
				service neutron-plugin-linuxbridge-agent restart > /dev/null 2>&1
				service neutron-metadata-agent restart > /dev/null 2>&1
				until cat /var/log/neutron/dhcp-agent.log | grep -m 1 "DHCP agent started"; do : ; done > /dev/null 2>&1
				sleep 3

				if ! pgrep neutron-server >/dev/null 2>&1; then step_failed; fi

				rm -f /var/lib/neutron/neutron.sqlite

				dialog 	--ok-label "Continue" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--msgbox  " Neutron - Networking Service setup completed." 5 120

				restart_apache2 > /dev/null 2>&1

    			2.11 ;;
			1)
				menu ;;
  			255)
    			echo "ESC pressed.";;
		esac
	else
		wrong_server
	fi
}

# 2.11 -----------------------------------------------------------------------------------

2.11 () {

	check_internet_access

	if [ "$(hostname)" = "controller" ]; then

		load_passwords

		$DIALOG --colors \
				--clear \
				--title " 2.11 - Create virtual networks, security group rules and adding public key " \
				--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
				--yes-label "Continue" \
				--no-label "Exit" \
        		--yesno "\n\
This step creates the necessary virtual networks to support launching one more instances. \
Example networking options includes one public virtual network, one private virtual \
network, and one instance that uses each network. The steps in this section use \
command-line interface (CLI) tools on the controller node.\n\n\
Steps to create virtual networks\n\n\
1) ${bold}Create the shared public network - 9.100.16.0/24${clear}\n\
2) ${bold}Create the private project network for Demo Project - 172.16.1.0/24${clear}\n\
3) ${bold}Add security group rules to allow all port access and permit ping (ICMP) requests${clear}\n\
4) ${bold}Add existing public key to avoid of conventional password authentication${clear}\n" 16 120

		case $? in

  			0)
				sleep 1

				restart_apache2 > /dev/null 2>&1

				rootpath=/root
				. $rootpath/admin-openrc.sh
				openstack token issue > /dev/null 2>&1


				. $rootpath/admin-openrc.sh 2>&1 | \
				dialog 	--title " Loading the admin-openrc.sh file to to gain access to admin-only CLI commands " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				neutron net-create public --shared --provider:physical_network public --provider:network_type flat 2>&1 | \
				dialog 	--title " Creating the public network " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				neutron net-show public 2>&1 | \
				dialog 	--title " Verifying the public network " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				neutron subnet-create public 9.100.16.0/24 --name public --allocation-pool \
				start=9.100.16.10,end=9.100.16.200 --dns-nameserver 8.8.4.4 --gateway 9.100.16.1 2>&1 | \
				dialog 	--title " Create a subnet on the public network " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				neutron subnet-show public 2>&1 | \
				dialog 	--title " Verifying the subnet on the public network " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				. $rootpath/demo-openrc.sh
				openstack token issue > /dev/null 2>&1

				. $rootpath/demo-openrc.sh 2>&1 | \
				dialog 	--title " Loading the demo-openrc.sh file to to gain access to Demo Project " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				neutron net-create private 2>&1 | \
				dialog 	--title " Creating private project network " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				neutron net-show private 2>&1 | \
				dialog 	--title " Verifying the private project network " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				neutron subnet-create private 172.16.1.0/24 --name private --dns-nameserver 8.8.4.4 --gateway 172.16.1.1 2>&1 | \
				dialog 	--title " Create a subnet on the private project network " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				neutron subnet-show private 2>&1 | \
				dialog 	--title " Verifying the subnet on the private network " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				. $rootpath/admin-openrc.sh
				openstack token issue > /dev/null 2>&1

				. $rootpath/admin-openrc.sh 2>&1 | \
				dialog 	--title " Loading the admin-openrc.sh file to to gain access to admin-only CLI commands " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				neutron net-update public --router:external 2>&1 | \
				dialog 	--title " Adding the router: external option to the public provider network " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				neutron net-external-list  2>&1 | \
				dialog 	--title " Verifying the list of external networks " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				. $rootpath/demo-openrc.sh
				openstack token issue > /dev/null 2>&1

				. $rootpath/demo-openrc.sh 2>&1 | \
				dialog 	--title " Loading the demo-openrc.sh file to to gain access to Demo Project " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				neutron router-create router 2>&1 | \
				dialog 	--title " Creating virtual router to connect private project networks to public provider networks " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				neutron router-show router  2>&1 | \
				dialog 	--title " Verifying the router " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				neutron router-interface-add router private 2>&1 | \
				dialog 	--title " Adding the private network subnet as an interface on the router " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				neutron router-gateway-set router public 2>&1 | \
				dialog 	--title " Setting a gateway on the public network on the router " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				( nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0 && \
				nova secgroup-add-rule default tcp 1 65535 0.0.0.0/0 ) 2>&1 | \
				dialog 	--title " Adding security group rules for allowing all ports and ICMP requests " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				nova keypair-add --pub-key .ssh/id_rsa.pub mykey 2>&1 | \
				dialog 	--title " Adding existing public key" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				nova keypair-list 2>&1 | \
				dialog 	--title " Verifying addition of the key pair" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				dialog 	--ok-label "Continue" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--msgbox  " Public, private project network, security group rules and public key are created. " 5 120

				restart_apache2 > /dev/null 2>&1

    			2.12 ;;
  			1)
				menu ;;
  			255)
    			echo "ESC pressed.";;
		esac
	else
		wrong_server
	fi
}

# 2.12 -----------------------------------------------------------------------------------

2.12 () {

	check_internet_access

	if [ "$(hostname)" = "controller" ]; then

		load_passwords

		$DIALOG --colors \
				--clear \
				--title " 2.12 - Horizon - OpenStack Dashboard " \
				--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
				--yes-label "Continue" \
				--no-label "Exit" \
        		--yesno "\n\
The OpenStack Dashboard, also known as horizon is a web interface that enables cloud \
administrators and users to manage various OpenStack resources and services.\n\n\
The Dashboard enables web-based interactions with the OpenStack Compute cloud controller \
through the OpenStack APIs.\n\n\
${info}You can access the dashboard using a web browser at http://controller/horizon${clear}\n\n\
Steps to install Horizon - OpenStack Dashboard\n\n\
1) ${bold}Install and configure Horizon components${clear}\n\
2) ${bold}Download preconfigured /etc/openstack-dashboard/local_settings.py${clear}\n\
3) ${bold}Reloading the web server configuration to load Horizon${clear}\n" 17 120

		case $? in
  			0)
				sleep 1

				restart_apache2 > /dev/null 2>&1

				rootpath=/root
				. $rootpath/admin-openrc.sh
				openstack token issue > /dev/null 2>&1


				(apt-get -y install openstack-dashboard && sleep 5 && \
				apt-get -y remove --auto-remove openstack-dashboard-ubuntu-theme ) 2>&1 | \
				dialog 	--title " Installing the Horizon packages " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! apt-get -qq install openstack-dashboard; then step_failed ; fi

				wget -O /etc/openstack-dashboard/local_settings.py $repo/$(hostname)/local_settings.py 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/openstack-dashboard/local_settings.py file " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "horizon" /etc/openstack-dashboard/local_settings.py; then step_failed; fi

				dialog  --clear\
						--exit-label Continue \
						--title " Review new /etc/openstack-dashboard/local_settings.py file." \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/openstack-dashboard/local_settings.py 40 120

				service apache2 reload 2>&1 | \
				dialog 	--title " Reloading the web server configuration " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				dialog 	--colors \
						--ok-label "Continue" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--msgbox  "\n\
		Horizon - Dashboard Service setup completed. \n\n\
		You can access the dashboard using a web browser at ${info}http://controller/horizon${clear}\n\n\
		User:       ${bold}admin${clear}\n\
		Password:   ${bold}${ADMIN_PASS}${clear}\n\n\
		User:       ${bold}demo${clear}\n\
		Password:   ${bold}${DEMO_PASS}${clear}" 15 120

				restart_apache2 > /dev/null 2>&1

    			2.13 ;;
  			1)
				menu ;;
  			255)
    			echo "ESC pressed.";;
		esac
	else
		wrong_server
	fi
}

# 2.13 -----------------------------------------------------------------------------------

2.13 () {

	check_internet_access

	if [ "$(hostname)" = "controller" ]; then

		load_passwords

		$DIALOG --colors \
				--clear \
				--title " 2.13 - Cinder - Block Storage Service " \
				--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
				--yes-label "Continue" \
				--no-label "Exit" \
        		--yesno "\n\
The OpenStack Block Storage service provides block storage devices to guest instances. \
The method in which the storage is provisioned and consumed is determined by the Block \
Storage driver, or drivers in the case of a multi-backend configuration. There are a \
variety of drivers that are available: NAS/SAN, NFS, iSCSI, Ceph, and more. The Block \
Storage API and scheduler services typically run on the controller nodes.\n\n\
${info}This service require at least 1 individual cinder node (block1) !${clear}\n\n\
Steps to install Cinder - Block Storage Service\n\n\
1) ${bold}Create Cinder database${clear}\n\
2) ${bold}Create the service credentials${clear}\n\
3) ${bold}Create the Block Storage service API endpoints${clear}\n\
4) ${bold}Install and configure Cinder components${clear}\n\
5) ${bold}Download preconfigured /etc/cinder/cinder.conf${clear}\n\
6) ${bold}Populate the Block Storage service database${clear}\n\
7) ${bold}Restart cinder and related services${clear}\n" 22 120

		case $? in
  			0)
				sleep 1

				restart_apache2 > /dev/null 2>&1

				rootpath=/root
				. $rootpath/admin-openrc.sh
				openstack token issue > /dev/null 2>&1


				mysql -uroot -p$ROOT_DB_PASS -e "CREATE DATABASE cinder"
				mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY '$CINDER_DBPASS'"
				mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY '$CINDER_DBPASS'"

				dialog 	--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--infobox "Creating cinder database..." 4 120 ; sleep $speed

				. $rootpath/admin-openrc.sh 2>&1 | \
				dialog 	--title " Loading the admin-openrc.sh file to to gain access to admin-only CLI commands " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack token issue 2>&1 | \
				dialog 	--title " Requesting an authentication token for admin user " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack user create --password $CINDER_PASS cinder 2>&1 | \
				dialog 	--title " Creating the cinder user " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack role add --project service --user cinder admin 2>&1 | \
				dialog 	--title " Adding the admin role to the cinder user and service project " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack service create --name cinder --description "OpenStack Block Storage" volume 2>&1 | \
				dialog 	--title " Creating the cinder service entity " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2 2>&1 | \
				dialog 	--title " Creating the cinder service entity " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne volume public http://controller:8776/v1/%\(tenant_id\)s 2>&1 | \
				dialog 	--title " Creating the Block Storage service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne volume internal http://controller:8776/v1/%\(tenant_id\)s 2>&1 | \
				dialog 	--title " Creating the Block Storage service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne volume admin http://controller:8776/v1/%\(tenant_id\)s 2>&1 | \
				dialog 	--title " Creating the Block Storage service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne volumev2 public http://controller:8776/v2/%\(tenant_id\)s 2>&1 | \
				dialog 	--title " Creating the Block Storage service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne volumev2 internal http://controller:8776/v2/%\(tenant_id\)s 2>&1 | \
				dialog 	--title " Creating the Block Storage service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne volumev2 admin http://controller:8776/v2/%\(tenant_id\)s 2>&1 | \
				dialog 	--title " Creating the Block Storage service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				apt-get -y install cinder-api cinder-scheduler python-cinderclient 2>&1 | \
				dialog 	--title " Installing the Cinder packages " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! apt-get -qq install cinder-api cinder-scheduler python-cinderclient; then step_failed ; fi

				wget -O /etc/cinder/cinder.conf $repo/$(hostname)/cinder.conf 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/cinder/cinder.conf file " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "controller" /etc/cinder/cinder.conf; then step_failed; fi

				dialog  --clear\
						--exit-label Continue \
						--title " Review new /etc/cinder/cinder.conf file." \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/cinder/cinder.conf 40 120

				pw_update /etc/cinder/cinder.conf

				su -s /bin/sh -c "cinder-manage db sync" cinder 2>&1 | \
				dialog 	--title " Populating the Block Storage service database " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				( service nova-api restart && \
				service cinder-scheduler restart && \
				service cinder-api restart ) 2>&1 | \
				dialog 	--title " Restarting cinder and related services " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! pgrep nova-api >/dev/null 2>&1; then step_failed; fi
				if ! pgrep cinder-api >/dev/null 2>&1; then step_failed; fi

				rm -f /var/lib/cinder/cinder.sqlite

				dialog 	--ok-label "Continue" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--msgbox  " Cinder - Block Storage setup completed." 5 120

				restart_apache2 > /dev/null 2>&1

   				2.14 ;;
			1)
				menu ;;
			255)
    			echo "ESC pressed.";;
		esac 
	else
		wrong_server
	fi
}

# 2.14 -----------------------------------------------------------------------------------

2.14 () {

	check_internet_access

	if [ "$(hostname)" = "controller" ]; then

		load_passwords

		$DIALOG --colors \
				--clear \
				--title " 2.14 - Swift - Object Storage Service " \
				--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
				--yes-label "Continue" \
				--no-label "Exit" \
        		--yesno "\n\
The OpenStack Object Storage is a multi-tenant object storage system. It is highly \
scalable and can manage large amounts of unstructured data at low cost through a \
RESTful HTTP API.\n\n\
${info}This service require at least 2 individual swift node (object1 and object2) !${clear}\n\n\
Steps to install Swift - Object Storage Service\n\n\
1) ${bold}Create the service credentials${clear}\n\
2) ${bold}Create the Object Storage service API endpoints${clear}\n\
3) ${bold}Install and configure Swift components${clear}\n\
4) ${bold}Download preconfigured /etc/swift/proxy-server.conf${clear}\n\
5) ${bold}Download preconfigured /etc/swift/swift.conf${clear}\n\
6) ${bold}Create initial rings${clear}\n\
7) ${bold}Restart swift and related services${clear}\n" 19 120

		case $? in
  			0)
				sleep 1

				restart_apache2 > /dev/null 2>&1

				rootpath=/root
				. $rootpath/admin-openrc.sh
				openstack token issue > /dev/null 2>&1

				. $rootpath/admin-openrc.sh 2>&1 | \
				dialog 	--title " Loading the admin-openrc.sh file to to gain access to admin-only CLI commands " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack token issue 2>&1 | \
				dialog 	--title " Requesting an authentication token for admin user " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack user create --domain default --password $SWIFT_PASS swift 2>&1 | \
				dialog 	--title " Creating the swift user " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack role add --project service --user swift admin 2>&1 | \
				dialog 	--title " Adding the admin role to the swift user and service project " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack service create --name swift --description "OpenStack Object Storage" object-store 2>&1 | \
				dialog 	--title " Creating the swift service entity " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne object-store public http://controller:8080/v1/AUTH_%\(tenant_id\)s 2>&1 | \
				dialog 	--title " Create the Object Storage service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne object-store internal http://controller:8080/v1/AUTH_%\(tenant_id\)s 2>&1 | \
				dialog 	--title " Create the Object Storage service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne object-store admin http://controller:8080/v1 2>&1 | \
				dialog 	--title " Create the Object Storage service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				apt-get -y install swift swift-proxy python-swiftclient \
				python-keystoneclient python-keystonemiddleware memcached 2>&1 | \
				dialog 	--title " Installing the Swift packages " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! apt-get -qq install swift swift-proxy python-swiftclient; then step_failed ; fi

				mkdir /etc/swift

				wget -O /etc/swift/proxy-server.conf $repo/$(hostname)/proxy-server.conf 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/swift/proxy-server.conf file " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "controller" /etc/swift/proxy-server.conf; then step_failed; fi

				wget -O /etc/swift/swift.conf $repo/$(hostname)/swift.conf 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/swift/swift.conf file " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "swift_hash_path_suffix" /etc/swift/swift.conf; then step_failed; fi

				dialog  --clear\
						--exit-label Continue \
						--title " Review /etc/swift/proxy-server.conf file." \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/swift/proxy-server.conf 40 120

				dialog  --clear\
						--exit-label Continue \
						--title " Review /etc/swift/swift.conf file." \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/swift/swift.conf 40 120

				pw_update /etc/swift/proxy-server.conf
				pw_update /etc/swift/swift.conf

				cd /etc/swift/

				( swift-ring-builder account.builder create 10 3 1 && \
				swift-ring-builder account.builder add --region 1 --zone 1 --ip 10.0.0.40 --port 6002 --device sdb --weight 100 && \
				swift-ring-builder account.builder add --region 1 --zone 2 --ip 10.0.0.40 --port 6002 --device sdc --weight 100 && \
				swift-ring-builder account.builder add --region 1 --zone 3 --ip 10.0.0.41 --port 6002 --device sdb --weight 100 && \
				swift-ring-builder account.builder add --region 1 --zone 4 --ip 10.0.0.41 --port 6002 --device sdc --weight 100 && \
				swift-ring-builder account.builder && \
				swift-ring-builder account.builder rebalance ) 2>&1 | \
				dialog 	--title " Creating swift account initial ring " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed


				( swift-ring-builder container.builder create 10 3 1 && \
				swift-ring-builder container.builder add --region 1 --zone 1 --ip 10.0.0.40 --port 6001 --device sdb --weight 100 && \
				swift-ring-builder container.builder add --region 1 --zone 2 --ip 10.0.0.40 --port 6001 --device sdc --weight 100 && \
				swift-ring-builder container.builder add --region 1 --zone 3 --ip 10.0.0.41 --port 6001 --device sdb --weight 100 && \
				swift-ring-builder container.builder add --region 1 --zone 4 --ip 10.0.0.41 --port 6001 --device sdc --weight 100 && \
				swift-ring-builder container.builder && \
				swift-ring-builder container.builder rebalance ) 2>&1 | \
				dialog 	--title " Creating swift container initial ring " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed


				( swift-ring-builder object.builder create 10 3 1 && \
				swift-ring-builder object.builder add --region 1 --zone 1 --ip 10.0.0.40 --port 6000 --device sdb --weight 100 && \
				swift-ring-builder object.builder add --region 1 --zone 2 --ip 10.0.0.40 --port 6000 --device sdc --weight 100 && \
				swift-ring-builder object.builder add --region 1 --zone 3 --ip 10.0.0.41 --port 6000 --device sdb --weight 100 && \
				swift-ring-builder object.builder add --region 1 --zone 4 --ip 10.0.0.41 --port 6000 --device sdc --weight 100 && \
				swift-ring-builder object.builder && \
				swift-ring-builder object.builder rebalance ) 2>&1 | \
				dialog 	--title " Creating swift object initial ring " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				chown -R root:swift /etc/swift

				(/etc/init.d/memcached restart && service apache2 restart &&  \
				/etc/init.d/swift-proxy restart ) 2>&1 | \
				dialog 	--title " Restarting swift and related services " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! pgrep memcached >/dev/null 2>&1; then step_failed; fi
				if ! pgrep apache2 >/dev/null 2>&1; then step_failed; fi
				if ! pgrep swift-proxy >/dev/null 2>&1; then step_failed; fi

				dialog 	--ok-label "Continue" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--msgbox  " Swift - Object Storage setup completed." 5 120
				cd

				restart_apache2 > /dev/null 2>&1

   				2.15 ;;
			1)
				menu ;;
			255)
    			echo "ESC pressed.";;
		esac
	else
		wrong_server
	fi
}

# 2.15 -----------------------------------------------------------------------------------

2.15 () {

	check_internet_access

	if [ "$(hostname)" = "controller" ]; then

		load_passwords

		$DIALOG --colors \
				--clear \
				--title " 2.15 - Heat - Orchestration Service " \
				--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
				--yes-label "Continue" \
				--no-label "Exit" \
        		--yesno "\n\
The Orchestration service provides a template-based orchestration for describing a cloud \
application by running OpenStack API calls to generate running cloud applications. The \
software integrates other core components of OpenStack into a one-file template system. \
The templates allow you to create most OpenStack resource types, such as instances, \
floating IPs, volumes, security groups and users. It also provides advanced \
functionality, such as instance high availability, instance auto-scaling, and nested \
stacks. This enables OpenStack core projects to receive a larger user base.\n\n\
Steps to install Heat - Orchestration Service\n\n\
1) ${bold}Create Heat database${clear}\n\
2) ${bold}Create the service credentials${clear}\n\
3) ${bold}Create the Orchestration service API endpoints${clear}\n\
4) ${bold}Install and configure Heat components${clear}\n\
5) ${bold}Download preconfigured /etc/heat/heat.conf${clear}\n\
7) ${bold}Populate the Orchestration service database${clear}\n\
8) ${bold}Restart heat and related services${clear}\n" 21 120

		case $? in
  			0)
				sleep 1

				service apache2 restart  > /dev/null 2>&1
				restart_apache2 > /dev/null 2>&1

				rootpath=/root
				. $rootpath/admin-openrc.sh
				openstack token issue > /dev/null 2>&1

				mysql -uroot -p$ROOT_DB_PASS -e "CREATE DATABASE heat"
				mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'localhost' IDENTIFIED BY '$HEAT_DBPASS'"
				mysql -uroot -p$ROOT_DB_PASS -e "GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'%' IDENTIFIED BY '$HEAT_DBPASS'"

				dialog 	--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--infobox "Creating heat database..." 4 120 ; sleep $speed

				. $rootpath/admin-openrc.sh 2>&1 | \
				dialog 	--title " Loading the admin-openrc.sh file to to gain access to admin-only CLI commands " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack token issue 2>&1 | \
				dialog 	--title " Requesting an authentication token for admin user " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack user create --domain default --password $HEAT_PASS heat 2>&1 | \
				dialog 	--title " Creating the heat user " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack role add --project service --user heat admin 2>&1 | \
				dialog 	--title " Adding the admin role to the heat user and service project " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack service create --name heat --description "Orchestration" orchestration 2>&1 | \
				dialog 	--title " Creating the heat service entity " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack service create --name heat-cfn --description "Orchestration" cloudformation 2>&1 | \
				dialog 	--title " Creating the heat service entity " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne orchestration public http://controller:8004/v1/%\(tenant_id\)s 2>&1 | \
				dialog 	--title " Creating the Orchestration service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne orchestration internal http://controller:8004/v1/%\(tenant_id\)s 2>&1 | \
				dialog 	--title " Creating the Orchestration service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne orchestration admin http://controller:8004/v1/%\(tenant_id\)s 2>&1 | \
				dialog 	--title " Creating the Orchestration service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne cloudformation public http://controller:8000/v1 2>&1 | \
				dialog 	--title " Creating the Orchestration service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne cloudformation internal http://controller:8000/v1 2>&1 | \
				dialog 	--title " Creating the Orchestration service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack endpoint create --region RegionOne cloudformation admin http://controller:8000/v1 2>&1 | \
				dialog 	--title " Creating the Orchestration service API endpoints " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack domain create --description "Stack projects and users" heat 2>&1 | \
				dialog 	--title " Creating the heat domain that contains projects and users for stacks " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack user create --domain heat --password $HEAT_DOMAIN_PASS heat_domain_admin 2>&1 | \
				dialog 	--title " Creating the heat_domain_admin user to manage projects and users in the heat domain " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack role add --domain heat --user heat_domain_admin admin 2>&1 | \
				dialog 	--title " Adding the admin role to the heat_domain_admin user in the heat domain  " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack role create heat_stack_owner 2>&1 | \
				dialog 	--title " Creating the heat_stack_owner role " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack role add --project demo --user demo heat_stack_owner 2>&1 | \
				dialog 	--title " Adding the heat_stack_owner role to the demo project and user  " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				openstack role create heat_stack_user 2>&1 | \
				dialog 	--title " Creating the heat_stack_user role " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				apt-get -y install heat-api heat-api-cfn heat-engine python-heatclient 2>&1 | \
				dialog 	--title " Installing the Heat packages " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! apt-get -qq install heat-api heat-api-cfn heat-engine python-heatclient; then step_failed ; fi

				wget -O /etc/heat/heat.conf $repo/$(hostname)/heat.conf 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/heat/heat.conf file " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "controller" /etc/heat/heat.conf; then step_failed; fi

				dialog  --clear\
						--exit-label Continue \
						--title " Review /etc/heat/heat.conf file." \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/heat/heat.conf 40 120

				pw_update /etc/heat/heat.conf

				su -s /bin/sh -c "heat-manage db_sync" heat 2>&1 | \
				dialog 	--title " Populating the Orchestration Service database " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				( service heat-api restart && \
				service heat-api-cfn restart && \
				service heat-engine restart ) 2>&1 | \
				dialog 	--title " Restarting heat and related services " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! pgrep heat-api >/dev/null 2>&1; then step_failed; fi
				if ! pgrep heat-api-cfn >/dev/null 2>&1; then step_failed; fi
				if ! pgrep heat-engine >/dev/null 2>&1; then step_failed; fi

				rm -f /var/lib/heat/heat.sqlite

				dialog 	--ok-label "Continue" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--msgbox  " Heat - Orchestration Service setup completed." 5 120

				restart_apache2 > /dev/null 2>&1

    			reboot_now ;;
  			1)
				menu ;;
  			255)
    			echo "ESC pressed.";;
		esac 
	else
		wrong_server
	fi
}

# 3.0 ------------------------------------------------------------------------------------

3.0 () {

	check_internet_access

	if [ "$(hostname)" = "compute1" ] || [ "$(hostname)" = "compute2" ]; then

		$DIALOG --colors \
				--title " 3.0 - Compute Node Installation " --clear \
				--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
				--yes-label "Continue" \
				--no-label "Exit" \
        		--yesno "\n\
This step will focus on install and configure the ${bold}Compute Service${clear} on ${info}$(hostname)${clear} node.\n\n\
The service supports several hypervisors to deploy instances or VMs. For simplicity, this configuration uses the ${bold}generic QEMU hypervisor${clear} compute nodes that doesn't support hardware acceleration for virtual machines since hardware nodes are also virtualized by VirtualBox in this example.\n\n\
This step assumes that ${bold}you completed following steps on controller node${clear}: \n\n\
- ${bold}2.9 - Nova - Compute Service${clear}\n\
- ${bold}2.10 - Neutron - Networking Service${clear}\n\n\
Also, make sure the ${bold}controller node is powered on${clear} to synchronize installation passwords and services.\n\n\
Steps to install Compute Node\n\n\
1) ${bold}Synchronize passwords from controller node${clear}\n\
2) ${bold}Download and configure Nova Compute Service${clear}\n\
3) ${bold}Download and configure Neutron Linuxbridge Agent${clear}\n" 23 120

		case $? in
  			0)
				sleep 1

				scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r root@controller:/root/passwords /root/passwords 2>&1 | \
				dialog 	--title " Synchronize passwords from controller node. " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "ADMIN_PASS" /root/passwords; then step_failed; fi

				dialog 	--ok-label "Continue" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--msgbox  "Passwords file copied to /root/passwords" 5 120
				3.1 ;;
  			1)
				menu;;
  			255)
    			echo "ESC pressed.";;
		esac
	else
		wrong_server
	fi
}

# 3.1 ------------------------------------------------------------------------------------

3.1 () {

	check_internet_access

	if [ "$(hostname)" = "compute1" ] || [ "$(hostname)" = "compute2" ]; then

		$DIALOG --colors \
				--title " 3.1 - Nova - Compute Service " --clear \
				--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
				--yes-label "Continue" \
				--no-label "Exit" \
        		--yesno "\n\
As a part of Compute Service , Nova require individual compute nodes as hypervisor.\n\n\
Different than controller node, ${bold}compute nodes will only host nova-compute component${clear}.\n\n\
Steps to install Nova Compute Service in Compute Nodes\n\n\
1) ${bold}Install the nova-compute and sysfsutils packages${clear}\n\
2) ${bold}Download preconfigured /etc/nova/nova.conf and /etc/nova/nova-compute.conf files${clear}\n\
3) ${bold}Restart nova-compute service.${clear}\n" 14 120

		case $? in

  			0)
				sleep 1

				apt-get -y install nova-compute sysfsutils 2>&1 | \
				dialog 	--title " Installing the necessary Nova packages. " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! apt-get -qq install nova-compute sysfsutils; then step_failed ; fi

				wget -O /etc/nova/nova.conf $repo/$(hostname)/nova.conf 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/nova/nova.conf config file. " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "controller" /etc/nova/nova.conf; then step_failed; fi

				wget -O /etc/nova/nova-compute.conf $repo/$(hostname)/nova-compute.conf 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/nova/nova-compute.conf config file. " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "libvirt" /etc/nova/nova-compute.conf; then step_failed; fi

				dialog  --clear\
						--exit-label Continue \
						--title " Review /etc/nova/nova.conf " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/nova/nova.conf 40 120

				dialog  --clear\
						--exit-label Continue \
						--title " Review /etc/nova/nova-compute.conf " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/nova/nova-compute.conf 40 120

				pw_update /etc/nova/nova.conf

				service nova-compute restart 2>&1 | \
				dialog 	--title " Restarting nova compute service" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! pgrep nova-compute >/dev/null 2>&1; then step_failed; fi

				rm -f /var/lib/nova/nova.sqlite

				dialog 	--colors \
						--ok-label "Continue" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--msgbox  " Nova - Compute Service setup completed on ${info}$(hostname)${clear} node." 5 120

    			3.2 ;;
  			1)
				menu ;;
  			255)
    			echo "ESC pressed.";;
		esac
	else
		wrong_server
	fi
}

# 3.2 ------------------------------------------------------------------------------------

3.2 () {

	check_internet_access

	if [ "$(hostname)" = "compute1" ] || [ "$(hostname)" = "compute2" ]; then

		$DIALOG --colors \
				--title " 3.2 - Neutron - Networking Service " --clear \
				--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
				--yes-label "Continue" \
				--no-label "Exit" \
        		--yesno "\n\
As a part of Networking Service , Neutron require agent installation on compute nodes to handle connectivity and security groups for instances.\n\n\
Different than controller node, ${bold}compute nodes will only host Neutron Linuxbridge Agent plugin.${clear}\n\n\
Steps to install Neutron Networking Service in Compute Nodes\n\n\
1) ${bold}Install the neutron-plugin-linuxbridge-agent package${clear}\n\
2) ${bold}Download preconfigured /etc/neutron/neutron.conf and /etc/neutron/plugins/ml2/linuxbridge_agent.ini files${clear}\n\
3) ${bold}Restart nova-compute and neutron-plugin-linuxbridge-agent services.${clear}\n" 15 120

		case $? in

			0)
				sleep 1

				apt-get -y install neutron-plugin-linuxbridge-agent 2>&1 | \
				dialog 	--title " Installing the necessary Neutron packages. " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! apt-get -qq install neutron-plugin-linuxbridge-agent; then step_failed ; fi

				wget -O /etc/neutron/neutron.conf $repo/$(hostname)/neutron.conf 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/neutron/neutron.conf config file. " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "controller" /etc/neutron/neutron.conf; then step_failed; fi

				wget -O /etc/neutron/plugins/ml2/linuxbridge_agent.ini $repo/$(hostname)/linuxbridge_agent.ini 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/neutron/plugins/ml2/linuxbridge_agent.ini config file. " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "linux_bridge" /etc/neutron/plugins/ml2/linuxbridge_agent.ini; then step_failed; fi

				dialog  --clear\
						--exit-label Continue \
						--title " Review /etc/neutron/neutron.conf " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/neutron/neutron.conf 40 120

				dialog  --clear\
						--exit-label Continue \
						--title " Review /etc/neutron/plugins/ml2/linuxbridge_agent.ini " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/neutron/plugins/ml2/linuxbridge_agent.ini 40 120

				pw_update /etc/neutron/neutron.conf
				pw_update /etc/neutron/plugins/ml2/linuxbridge_agent.ini

				service nova-compute restart 2>&1 | \
				dialog 	--title " Restarting nova compute service" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! pgrep nova-compute >/dev/null 2>&1; then step_failed; fi

				service neutron-plugin-linuxbridge-agent restart 2>&1 | \
				dialog 	--title " Restarting Neutron Linuxbridge Agent service" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				rm -f /var/lib/nova/nova.sqlite

				dialog 	--colors \
						--ok-label "Continue" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--msgbox  " Neutron - Networking Service setup completed on ${info}$(hostname)${clear} node." 5 120

    			reboot_now ;;
    		1)
				menu ;;
			255)
    			echo "ESC pressed.";;
		esac
	else
		wrong_server
	fi
}

# 4.0 ------------------------------------------------------------------------------------

4.0 () {

	check_internet_access

	if [ "$(hostname)" = "block1" ]; then

		$DIALOG --colors \
				--title " 4.0 - Block Storage Node Installation " --clear \
				--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
				--yes-label "Continue" \
				--no-label "Exit" \
        		--yesno "\n\
This step install and configure storage node for the Block Storage service. For \
simplicity, this configuration references one storage node with an empty local block \
storage device.\n\n\
The service provisions logical volumes on this node using the LVM driver and provides them to instances via iSCSI transport.\n\n\
This step assumes that ${bold}you completed following step on controller node${clear}: \n\n\
- ${bold}2.13 - Cinder - Block Storage Service${clear}\n\n\
Also, make sure the ${bold}controller node is powered on${clear} to synchronize installation passwords and services.\n\n\
Steps to install Block Storage Node\n\n\
1) ${bold}Synchronize passwords from controller node${clear}\n\
1) ${bold}Download and install lvm2 supporting utility package${clear}\n\
2) ${bold}Create the LVM physical volume /dev/sdb${clear}\n\
3) ${bold}Create the LVM volume group cinder-volume${clear}\n\
4) ${bold}Download preconfigured /etc/lvm/lvm.conf${clear}\n\
5) ${bold}Install and configure cinder-volume component${clear}\n\
6) ${bold}Download preconfigured /etc/cinder/cinder.conf${clear}\n\
7) ${bold}Restart the Block Storage volume service${clear}\n" 25 120

		case $? in

  			0)

				sleep 1

				scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r root@controller:/root/passwords /root/passwords 2>&1 | \
				dialog 	--title " Downloading passwords file from controller node " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "ADMIN_PASS" /root/passwords; then step_failed; fi

				dialog 	--ok-label "Continue" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--msgbox  "Passwords file copied to /root/passwords" 5 120

				apt-get -y install lvm2 2>&1 | \
				dialog 	--title " Installing lvm2 supporting utility package " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! apt-get -qq install lvm2; then step_failed ; fi

				( pvcreate /dev/sdb && vgcreate cinder-volumes /dev/sdb ) 2>&1 | \
				dialog 	--title " Creating the LVM physical volume and volume group " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				wget -O /etc/lvm/lvm.conf $repo/$(hostname)/lvm.conf 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/lvm/lvm.conf config file " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "sdb" /etc/lvm/lvm.conf; then step_failed; fi

				dialog  --clear\
						--exit-label Continue \
						--title " Review /etc/lvm/lvm.conf " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/lvm/lvm.conf 40 120

				apt-get -y install cinder-volume python-mysqldb 2>&1 | \
				dialog 	--title " Installing cinder-volume component " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! apt-get -qq install cinder-volume python-mysqldb; then step_failed ; fi

				wget -O /etc/cinder/cinder.conf $repo/$(hostname)/cinder.conf 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/cinder/cinder.conf config file " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "controller" /etc/cinder/cinder.conf; then step_failed; fi

				dialog  --clear\
						--exit-label Continue \
						--title " Review /etc/cinder/cinder.conf " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/cinder/cinder.conf 40 120

				pw_update /etc/cinder/cinder.conf

				( service tgt restart && service cinder-volume restart ) 2>&1 | \
				dialog 	--title " Restarting Block Storage volume service " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! pgrep tgt >/dev/null 2>&1; then step_failed; fi
				if ! pgrep cinder-volume >/dev/null 2>&1; then step_failed; fi

				rm -f /var/lib/cinder/cinder.sqlite

				dialog 	--colors \
						--ok-label "Continue" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--msgbox  " Cinder - Block Storage Service setup completed on ${info}$(hostname)${clear} node." 5 120

				reboot_now ;;
  			1)
				menu;;
  			255)

    			echo "ESC pressed.";;
		esac
	else
		wrong_server
	fi
}

# 5.0 ------------------------------------------------------------------------------------

5.0 () {

	check_internet_access

	if [ "$(hostname)" = "object1" ] || [ "$(hostname)" = "object2" ]; then

		$DIALOG --colors \
				--title " 5.0 - Object Storage Node Installation " --clear \
				--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
				--yes-label "Continue" \
				--no-label "Exit" \
        		--yesno "\n\
This step will install and configure object storage nodes that operate the account, \
container, and object services. For simplicity, this example references two object \
storage nodes, each containing two empty local block storage devices (disk).\n\n\
This step assumes that ${bold}you completed following step on controller node${clear}:\n\n\
- ${bold}2.14 - Swift - Object Storage Service${clear}\n\n\
Also, make sure the ${bold}controller node is powered on${clear} to synchronize \
installation passwords, services and tokens..\n\n\
Steps to install Object Storage Node\n\n\
1) ${bold}Synchronize passwords from controller node${clear}\n\
2) ${bold}Prepare the storage devices and enable rsync service${clear}\n\
3) ${bold}Install and configure Swift Object Storage Service${clear}\n\
4) ${bold}Distribute initial rings and configuration files created in controller node.${clear}\n" 23 120

		case $? in

  			0)

				sleep 1

				scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r root@controller:/root/passwords /root/passwords 2>&1 | \
				dialog 	--title " Downloading passwords file from controller node " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "ADMIN_PASS" /root/passwords; then step_failed; fi

				dialog 	--ok-label "Continue" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--msgbox  "Passwords file copied to /root/passwords" 5 120

				apt-get -y install xfsprogs rsync 2>&1 | \
				dialog 	--title " Installing xfs supporting utility packages " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! apt-get -qq install xfsprogs; then step_failed ; fi

				( mkfs.xfs /dev/sdb && mkfs.xfs /dev/sdc ) 2>&1 | \
				dialog 	--title " Formatting the /dev/sdb and /dev/sdc devices as XFS " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				( mkdir -p /srv/node/sdb && mkdir -p /srv/node/sdc ) 2>&1 | \
				dialog 	--title " Creating the mount point directory structure " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				dialog 	--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--infobox " Editing fstab to automount partitions at startup " 4 120 ; sleep $speed

				echo "/dev/sdb /srv/node/sdb xfs noatime,nodiratime,nobarrier,logbufs=8 0 2" >> /etc/fstab
				echo "/dev/sdc /srv/node/sdc xfs noatime,nodiratime,nobarrier,logbufs=8 0 2" >> /etc/fstab

				( mount /srv/node/sdb && mount /srv/node/sdc ) 2>&1 | \
				dialog 	--title " Mounting the devices " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				wget -O /etc/rsyncd.conf $repo/$(hostname)/rsyncd.conf 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/rsyncd.conf config file " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "swift" /etc/rsyncd.conf; then step_failed; fi

				wget -O /etc/default/rsync $repo/$(hostname)/rsync	 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/default/rsync config file. " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "true" /etc/default/rsync; then step_failed; fi

				dialog  --clear\
						--exit-label Continue \
						--title " Review /etc/rsyncd.conf " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/rsyncd.conf 40 120

				dialog  --clear\
						--exit-label Continue \
						--title " Review /etc/default/rsync " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/default/rsync 40 120

				service rsync start	 2>&1 | \
				dialog 	--title " Starting rync service. " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				apt-get -y install swift swift-account swift-container swift-object	 2>&1 | \
				dialog 	--title " Installing swift components " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! apt-get -qq install swift swift-account swift-container swift-object; then step_failed ; fi

				wget -O /etc/swift/object-server.conf $repo/$(hostname)/object-server.conf 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/swift/object-server.conf config file " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "10.0.0" /etc/swift/object-server.conf; then step_failed; fi

				wget -O /etc/swift/container-server.conf $repo/$(hostname)/container-server.conf 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/swift/container-server.conf config file " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "10.0.0" /etc/swift/container-server.conf; then step_failed; fi

				wget -O /etc/swift/account-server.conf $repo/$(hostname)/account-server.conf 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/swift/account-server.conf config file " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "10.0.0" /etc/swift/account-server.conf; then step_failed; fi

				dialog  --clear\
						--exit-label Continue \
						--title " Review /etc/swift/object-server.conf " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/default/rsync 40 120

				dialog  --clear\
						--exit-label Continue \
						--title " Review /etc/swift/container-server.conf " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/default/rsync 40 120

				dialog  --clear\
						--exit-label Continue \
						--title " Review /etc/swift/account-server.conf " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/default/rsync 40 120

				dialog 	--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--infobox "Setting folder permissions" 4 120 ; sleep $speed

				chown -R swift:swift /srv/node
				mkdir -p /var/cache/swift
				chown -R root:swift /var/cache/swift

				scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r root@controller:/etc/swift/account.ring.gz /etc/swift/account.ring.gz 2>&1 | \
				dialog 	--title " Downloading account ring from controller node " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r root@controller:/etc/swift/container.ring.gz /etc/swift/container.ring.gz 2>&1 | \
				dialog 	--title " Downloading container ring from controller node " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r root@controller:/etc/swift/object.ring.gz /etc/swift/object.ring.gz 2>&1 | \
				dialog 	--title " Downloading object ring from controller node " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				wget -O /etc/swift/swift.conf $repo/$(hostname)/swift.conf 2>&1 | \
				dialog 	--title " Downloading preconfigured /etc/swift/swift.conf config file " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				if ! grep -q "swift_hash_path_suffix" /etc/swift/swift.conf; then step_failed; fi

				dialog  --clear\
						--exit-label Continue \
						--title " Review /etc/swift/swift.conf " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--textbox /etc/swift/swift.conf 40 120

				pw_update /etc/swift/swift.conf

				dialog 	--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--infobox "Setting folder permissions" 4 120 ; sleep $speed

				chown -R root:swift /etc/swift
				chown -R swift:swift /srv/node/

				swift-init all start 2>&1 | \
				dialog 	--title " Starting swift services " \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--progressbox 40 120; sleep $speed

				dialog 	--colors \
						--ok-label "Continue" \
						--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
						--msgbox  "Swift - Object Storage Service setup completed on ${info}$(hostname)${clear} node." 5 120

				reboot_now ;;
  			1)
				menu;;
  			255)
    			echo "ESC pressed.";;
		esac
	else
	wrong_server
	fi
}

# menu -----------------------------------------------------------------------------------

menu () {

check_internet_access

speed_menu

if [ "$(hostname)" = "controller" ]; then
   	menumsg="${bold}Current Status:${clear} ${info}Node selection found, this is $(hostname) \
node.${clear}\n\nNext step selected, '${bold}2 - Controller Node Installation${clear}'.\n\n"
	defaultitem="2.0"

elif [ "$(hostname)" = "compute1" ] || [ "$(hostname)" = "compute2" ]; then
   	menumsg="${bold}Current Status:${clear} ${info}Node selection found, this is $(hostname) \
node.${clear}\n\nNext step selected, '${bold}3 - Compute Node Installation${clear}'.\n\n"
   	defaultitem="3.0"

elif [ "$(hostname)" = "block1" ]; then
   	menumsg="${bold}Current Status:${clear} ${info}Node selection found, this is $(hostname) \
node.${clear}\n\nNext step selected, '${bold}4 - Block Node Installation${clear}'.\n\n"
   	defaultitem="4.0"

elif [ "$(hostname)" = "object1" ] || [ "$(hostname)" = "object2" ]; then
   	menumsg="${bold}Current Status:${clear} ${info}Node selection found, this is $(hostname) \
node.${clear}\n\nNext step selected, '${bold}5 - Object Node Installation${clear}'.\n\n"
   	defaultitem="5.0"

else
	menumsg="${bold}Current Status:${clear} ${info}Node selection not found!${clear}\n\n\
${bold}1 - Prerequisites${clear} step selected to complete the node selection.\n\n"
   	defaultitem="1.0"

fi

$DIALOG	--colors \
		--clear --title " OpenStackLab Installer - Main Menu " \
		--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
        --default-item "$defaultitem" \
        --ok-label "Continue" \
        --cancel-label "Exit" \
        --menu "\n$menumsg" 43 120 33 \
"1.0" "${bold}Prerequisites${clear}" \
"1.1" "Review Example Architecture - Hardware Requirements" \
"1.2" "Review Example Architecture - Network Requirements" \
"1.3" "Prerequisites - Node Selection" \
"1.4" "Prerequisites - Node Networking Setup" \
"1.5" "Prerequisites - Network Time Protocol (NTP) Setup" \
"1.6" "Prerequisites - OpenStack Packages" \
"1.7" "Prerequisites - Reboot to Apply Changes" \
" " " " \
"2.0" "${bold}Controller Node Installation${clear}" \
"2.1" "Generate Passwords" \
"2.2" "SQL Database" \
"2.3" "RabbitMQ - Message queue" \
"2.4" "Keystone - Identity Service" \
"2.5" "Service entity and API endpoints" \
"2.6" "Create projects, users, and roles" \
"2.7" "OpenStack client environment scripts" \
"2.8" "Glance - Image Service" \
"2.9" "Nova - Compute Service" \
"2.10" "Neutron - Networking Service" \
"2.11" "Create virtual networks, security group rules and adding public key" \
"2.12" "Horizon - OpenStack Dashboard" \
"2.13" "Cinder - Block Storage Service" \
"2.14" "Swift - Object Storage Service" \
"2.15" "Heat - Orchestration Service" \
" " " " \
"3.0" "${bold}Compute Node Installation${clear}" \
"3.1" "Nova - Compute Service" \
"3.2" "Neutron - Networking Service" \
" " " " \
"4.0" "${bold}Block Storage Node Installation${clear}" \
" " " " \
"5.0" "${bold}Object Storage Node Installation${clear}" 2> $tempfile

retval=$?
choice=`cat $tempfile`
case $retval in
  0)
    $choice;;
  1)
    echo "Cancel pressed."
    clear
    exit 0 ;;
  255)
    echo "ESC pressed.";;
esac
}

# welcome --------------------------------------------------------------------------------

dialog 	--title " W E L C O M E " --clear \
		--backtitle "OpenStackLab for Cloud Advisors - ${version}" \
		--yes-label "Accept" \
		--no-label "Exit" \
        --yesno "\n\
#########   #############    ######     #######\n\
#########   ######  ######   #######   ########\n\
   ###        ###     ####      ##### ######\n\
   ###        ##########        ############\n\
   ###        ##########        ### #### ###\n\
   ###        ###    #####      ###  #   ###\n\
#########   ######  ######   ######      ######\n\
#########   #############    ######      ######\n\n\
---------------- O p e n S t a c k   L a b ----\n\
----------------------- for Cloud Advisors ----\n\n\n\n\
These scripts come without warranty of any kind. Use them at your own risk. I assume no \
liability for the accuracy, correctness, completeness, or usefulness of any information \
provided by this code nor for any sort of damages using these scripts may cause.\n\n\
Do you want to continue ?\n" 30 53

case $? in
  0)
  	check_internet_access
  	menu ;;
  1)
    clear
    exit 0 ;;
  255)
    clear
    echo "ESC pressed."
    exit 0 ;;
esac
