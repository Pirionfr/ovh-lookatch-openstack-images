#!/usr/bin/env bash

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."

if [ ! -f "$BASEDIR/.ovh.travis.gpg" ]; then
    echo "Missing .ovh.travis gpg key, won't be able to sign files" >&2
else
    gpg --import "$BASEDIR/.ovh.travis.gpg"
fi

if [ -z "$GPG_PASS" ]; then
    echo "Missing gpg passphrase, signing files may fail" >&2
else
    echo $GPG_PASS > "$BASEDIR/.gpg.passphrase"
fi

echo "Install Openstack & Swift CLI" >&2
sudo pip install --upgrade setuptools
sudo pip install --upgrade cryptography
sudo pip install python-openstackclient==3.15.0
sudo pip install python-swiftclient==3.3.0

echo "Creating ~/bin directory" >&2
mkdir -p ~/bin
export PATH="~/bin:$PATH"

echo "Installing Packer" >&2
curl -sLo packer.zip https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip
unzip packer.zip
mv packer ~/bin/packer

