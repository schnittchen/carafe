#!/bin/bash

set -x
set -e
set -u

sudo apt-get -qq update
sudo apt-get install -y ruby

cd ~; ssh-keygen -f ".ssh/id_rsa" -t rsa -N ""; cd -

# travis what are you doing there?
sudo rm /etc/profile.d/rvm.sh

sudo useradd -m user
sudo su -l user -c bash -c "mkdir .ssh && touch .ssh/authorized_keys"

pubfile=~/.ssh/id_rsa.pub
authfile=~user/.ssh/authorized_keys
sudo sh -c "cat $pubfile >> $authfile"

mkdir -p ~/.ssh
cat >> ~/.ssh/config <<EOF
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
  PasswordAuthentication=no
  IdentityFile ~/.ssh/id_rsa
EOF

ssh localhost -l user hostname
