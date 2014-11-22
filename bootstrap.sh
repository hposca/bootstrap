#!/usr/bin/env bash


if [ $(id -u) -ne 0 ]; then
    exec sudo $0;
else
    echo "Run this command as root, please."
    exit 1;
fi

# From this point onwards, everything is executed as root

apt-get update
apt-get install python-dev
pip install --upgrade pip
pip install --upgrade ansible

# TODO: Invoke ansible here
