#!/usr/bin/env bash

if [ $(id -u) -ne 0 ]; then
  echo "Run this command as root, please."
  exit 1;
fi

# From this point onwards, everything is executed as root

echo -e "\n$0: INFO: -- Before Installation -- Total number of packages installed: $(dpkg --get-selections | wc -l)\n"

echo -e "$0: Installing basic packages...\n"
apt-get update
apt-get install -y python-dev python-pip
pip install --upgrade pip
pip install --upgrade ansible

echo -e "$0: Invoking Ansible...\n"
ansible-playbook bootstrap.yml -i hosts

echo -e "\n$0: INFO: -- After Installation -- Total number of packages installed: $(dpkg --get-selections | wc -l)\n"
