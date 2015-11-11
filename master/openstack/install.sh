#!/bin/bash
cd

clear
read -r -p "1) Download and run password generator? [y/N] " response
case $response in
    [yY][eE][sS]|[yY]) 
        echo "Starting..."
curl -o /root/pw.sh https://raw.githubusercontent.com/mustafatoraman/openstack/master/master/pw.sh
sh pw.sh
rm -rf pw.sh
        ;;
    *)
        echo "Moving next step..."
        ;;
esac
