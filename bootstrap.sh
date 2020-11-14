#!/usr/bin/env bash

#real_user=$(logname)
real_user=$(who | tail | awk '{ print $1 }')
real_user_group=$(getent group $real_user | awk -F: '{ print $1 }')
real_user_home=$(eval echo ~$real_user)

if [ $(id -u) -ne 0 ]; then
  echo "Run this command as root, please."
  exit 1;
fi

# From this point onwards, everything is executed as root

packages_before=$(dpkg --get-selections | wc -l)

#echo -e "$0: Installing basic packages...\n"
#apt-get update
#apt-get install -y python3-dev python3-pip libssl-dev python3-setuptools python-apt
##export LC_ALL=C
#pip3 install --upgrade setuptools pip ansible testresources

echo -e "\n\n$0: Invoking Ansible...\n\n"
ansible-playbook -i hosts bootstrap.yml \
  -e real_user="${real_user}" \
  -e real_user_group="${real_user_group}" \
  -e real_user_home="${real_user_home}"

packages_after=$(dpkg --get-selections | wc -l)
echo -e "\n$0: INFO: -- Before Installation -- Total number of packages installed: $packages_before\n"
echo -e "\n$0: INFO: -- After Installation -- Total number of packages installed: $packages_after\n"
