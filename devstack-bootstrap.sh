#! /bin/bash

set -e

# Warm the PIP and APT cache
if [ $(ls -1 /vagrant/pip_cache/ | wc -l) -gt 0 ]
then
  echo "copying cached pip files"
	mkdir -p ~/.cache/pip/
	cp -R /vagrant/pip_cache/* ~/.cache/pip/
fi
if [ $(ls -1 /vagrant/apt_cache/ | wc -l) -gt 0 ]
then
  echo "copying cached apt files"
	sudo mkdir -p /var/cache/apt
	sudo cp -R /vagrant/apt_cache/* /var/cache/apt/
fi

# Make apt faster!
sudo sed -i 's/http:\/\/us.archive.ubuntu.com\/ubuntu\//mirror:\/\/mirrors.ubuntu.com\/mirrors.txt/g' /etc/apt/sources.list

sudo apt-get update
sudo apt-get install -qqy git ebtables bridge-utils

git clone https://github.com/openstack-dev/devstack.git

# Copy conf to be used
cp /vagrant/devstack.conf devstack/localrc

# Launch devstack!
cd devstack
./stack.sh

source openrc
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
nova secgroup-add-rule default tcp 80 80 0.0.0.0/0
nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0

cp -R ~/.cache/pip/ /vagrant/pip_cache || true
sudo cp -R /var/cache/apt/* /vagrant/apt_cache || true
