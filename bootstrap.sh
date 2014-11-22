#!/usr/bin/env bash

if [ $(id -u) -ne 0 ]; then
  echo "Run this command as root, please."
  exit 1;
fi

# From this point onwards, everything is executed as root

apt-get update
apt-get install -y python-dev python-pip
pip install --upgrade pip
pip install --upgrade ansible

# TODO: Invoke ansible here
ansible-playbook bootstrap.yml -i hosts
