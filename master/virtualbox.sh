#!/bin/bash

repo=https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/

# Download SSH Key #######################################################################
mv ~/.ssh ~/.ssh.bak
mkdir ~/.ssh
curl -o ~/.ssh/id_rsa $repo/ssh/id_rsa
curl -o ~/.ssh/id_rsa.pub $repo/ssh/id_rsa.pub
chmod 700 ~/.ssh/*

# Update Hosts File ######################################################################
sudo mv /etc/hosts /etc/hosts.bak
sudo curl -o /etc/hosts $repo/ssh/hosts

# Create Networks ########################################################################
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage natnetwork add --netname Management --network 10.0.0.0/24 --enable --dhcp off
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage natnetwork start --netname Management
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage natnetwork add --netname Public --network 9.100.16.0/24 --enable --dhcp off
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage natnetwork start --netname Public
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage hostonlyif create
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage hostonlyif ipconfig vboxnet0 -ip 172.16.0.1 --netmask 255.255.255.0
sleep 2

# Create Controller Node #################################################################
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage createvm --name controller --ostype "Ubuntu_64" --register
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm controller --cpus 2 --memory 6144
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage clonehd ~/Desktop/OpenStack\ Lab/clone.vdi ~/VirtualBox\ VMs/controller/controller.vdi --format VDI &&
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storagectl controller --name IDE --controller PIIX4 --add ide --bootable on
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storageattach controller --storagectl IDE --type dvddrive --port 1 --device 1 --medium  emptydrive
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storagectl controller --name SATA --controller IntelAhci --portcount 1 --add sata --bootable on --hostiocache on
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storageattach controller --storagectl SATA --type hdd --port 1 --device 0 --medium  ~/VirtualBox\ VMs/controller/controller.vdi
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm controller --nic1 hostonly --hostonlyadapter1 vboxnet0 --nicpromisc1 allow-all --macaddress1 auto
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm controller --nic2 natnetwork --nat-network2 Management --nicpromisc2 allow-all --macaddress2 auto
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm controller --nic3 natnetwork --nat-network3 Public --nicpromisc3 allow-all --macaddress3 auto
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm controller --boot1 dvd --boot2 disk --boot3 net --boot4  none
sleep 2

# Create Compute1 Node ###################################################################
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage createvm --name compute1 --ostype "Ubuntu_64" --register
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm compute1 --cpus 2 --memory 6144
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage clonehd ~/Desktop/OpenStack\ Lab/clone.vdi ~/VirtualBox\ VMs/compute1/compute1.vdi --format VDI &&
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storagectl compute1 --name IDE --controller PIIX4 --add ide --bootable on
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storageattach compute1 --storagectl IDE --type dvddrive --port 1 --device 1 --medium  emptydrive
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storagectl compute1 --name SATA --controller IntelAhci --portcount 1 --add sata --bootable on --hostiocache on
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storageattach compute1 --storagectl SATA --type hdd --port 1 --device 0 --medium  ~/VirtualBox\ VMs/compute1/compute1.vdi
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm compute1 --nic1 hostonly --hostonlyadapter1 vboxnet0 --nicpromisc1 allow-all --macaddress1 auto
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm compute1 --nic2 natnetwork --nat-network2 Management --nicpromisc2 allow-all --macaddress2 auto
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm compute1 --nic3 natnetwork --nat-network3 Public --nicpromisc3 allow-all --macaddress3 auto
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm compute1 --boot1 dvd --boot2 disk --boot3 net --boot4  none
sleep 2

# Create Compute2 Node ###################################################################
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage createvm --name compute2 --ostype "Ubuntu_64" --register
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm compute2 --cpus 2 --memory 6144
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage clonehd ~/Desktop/OpenStack\ Lab/clone.vdi ~/VirtualBox\ VMs/compute2/compute2.vdi --format VDI &&
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storagectl compute2 --name IDE --controller PIIX4 --add ide --bootable on
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storageattach compute2 --storagectl IDE --type dvddrive --port 1 --device 1 --medium  emptydrive
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storagectl compute2 --name SATA --controller IntelAhci --portcount 1 --add sata --bootable on --hostiocache on
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storageattach compute2 --storagectl SATA --type hdd --port 1 --device 0 --medium  ~/VirtualBox\ VMs/compute2/compute2.vdi
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm compute2 --nic1 hostonly --hostonlyadapter1 vboxnet0 --nicpromisc1 allow-all --macaddress1 auto
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm compute2 --nic2 natnetwork --nat-network2 Management --nicpromisc2 allow-all --macaddress2 auto
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm compute2 --nic3 natnetwork --nat-network3 Public --nicpromisc3 allow-all --macaddress3 auto
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm compute2 --boot1 dvd --boot2 disk --boot3 net --boot4  none

# Create Block1 Node #####################################################################
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage createvm --name block1 --ostype "Ubuntu_64" --register
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm block1 --cpus 1 --memory 1024
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage clonehd ~/Desktop/OpenStack\ Lab/clone.vdi ~/VirtualBox\ VMs/block1/block1-0.vdi --format VDI &&
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage createhd --filename ~/VirtualBox\ VMs/block1/block1-1 --size 1048576
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storagectl block1 --name IDE --controller PIIX4 --add ide --bootable on
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storageattach block1 --storagectl IDE --type dvddrive --port 1 --device 1 --medium  emptydrive
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storagectl block1 --name SATA --controller IntelAhci --portcount 2 --add sata --bootable on --hostiocache on
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storageattach block1 --storagectl SATA --type hdd --port 1 --device 0 --medium  ~/VirtualBox\ VMs/block1/block1-0.vdi
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storageattach block1 --storagectl SATA --type hdd --port 2 --device 0 --medium  ~/VirtualBox\ VMs/block1/block1-1.vdi
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm block1 --nic1 hostonly --hostonlyadapter1 vboxnet0 --nicpromisc1 allow-all --macaddress1 auto
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm block1 --nic2 natnetwork --nat-network2 Management --nicpromisc2 allow-all --macaddress2 auto
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm block1 --boot1 dvd --boot2 disk --boot3 net --boot4  none
sleep 2

# Create Object1 Node ####################################################################
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage createvm --name object1 --ostype "Ubuntu_64" --register
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm object1 --cpus 1 --memory 1024
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage clonehd ~/Desktop/OpenStack\ Lab/clone.vdi ~/VirtualBox\ VMs/object1/object1-0.vdi --format VDI &&
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage createhd --filename ~/VirtualBox\ VMs/object1/object1-1 --size 1048576
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage createhd --filename ~/VirtualBox\ VMs/object1/object1-2 --size 1048576
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storagectl object1 --name IDE --controller PIIX4 --add ide --bootable on
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storageattach object1 --storagectl IDE --type dvddrive --port 1 --device 1 --medium  emptydrive
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storagectl object1 --name SATA --controller IntelAhci --portcount 3 --add sata --bootable on --hostiocache on
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storageattach object1 --storagectl SATA --type hdd --port 1 --device 0 --medium  ~/VirtualBox\ VMs/object1/object1-0.vdi
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storageattach object1 --storagectl SATA --type hdd --port 2 --device 0 --medium  ~/VirtualBox\ VMs/object1/object1-1.vdi
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storageattach object1 --storagectl SATA --type hdd --port 3 --device 0 --medium  ~/VirtualBox\ VMs/object1/object1-2.vdi
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm object1 --nic1 hostonly --hostonlyadapter1 vboxnet0 --nicpromisc1 allow-all --macaddress1 auto
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm object1 --nic2 natnetwork --nat-network2 Management --nicpromisc2 allow-all --macaddress2 auto
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm object1 --boot1 dvd --boot2 disk --boot3 net --boot4  none
sleep 2

# Create Object2 Node ####################################################################
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage createvm --name object2 --ostype "Ubuntu_64" --register
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm object2 --cpus 1 --memory 1024
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage clonehd ~/Desktop/OpenStack\ Lab/clone.vdi ~/VirtualBox\ VMs/object2/object2-0.vdi --format VDI &&
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage createhd --filename ~/VirtualBox\ VMs/object2/object2-1 --size 1048576
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage createhd --filename ~/VirtualBox\ VMs/object2/object2-2 --size 1048576
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storagectl object2 --name IDE --controller PIIX4 --add ide --bootable on
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storageattach object2 --storagectl IDE --type dvddrive --port 1 --device 1 --medium  emptydrive
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storagectl object2 --name SATA --controller IntelAhci --portcount 3 --add sata --bootable on --hostiocache on
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storageattach object2 --storagectl SATA --type hdd --port 1 --device 0 --medium  ~/VirtualBox\ VMs/object2/object2-0.vdi
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storageattach object2 --storagectl SATA --type hdd --port 2 --device 0 --medium  ~/VirtualBox\ VMs/object2/object2-1.vdi
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage storageattach object2 --storagectl SATA --type hdd --port 3 --device 0 --medium  ~/VirtualBox\ VMs/object2/object2-2.vdi
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm object2 --nic1 hostonly --hostonlyadapter1 vboxnet0 --nicpromisc1 allow-all --macaddress1 auto
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm object2 --nic2 natnetwork --nat-network2 Management --nicpromisc2 allow-all --macaddress2 auto
/Applications/VirtualBox.app/Contents/MacOS/VBoxManage modifyvm object2 --boot1 dvd --boot2 disk --boot3 net --boot4 none
sleep 2
