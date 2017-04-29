#!/bin/bash

set -x
set -e
set -u

if ! which mix; then
  wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
  sudo dpkg -i erlang-solutions_1.0_all.deb
  sudo apt-get -qq update
  sudo apt-get install -y esl-erlang elixir
fi

sudo apt-get -qq update
sudo apt-get install -y ruby ruby-bundler

cd ~; mkdir -p .ssh; ssh-keygen -f ".ssh/id_rsa" -t rsa -N ""; cd -

# travis what are you doing there?
sudo rm -f /etc/profile.d/rvm.sh

sudo useradd -m user
sudo su -l user -c bash -c "mkdir .ssh && touch .ssh/authorized_keys && touch .pam_environment"

# Apparently travis manages elixir versions with kiex. Let's hope copying over the
# PATH env to the other user will be sufficient for a while.
# Also make sure plain processes executed via ssh (not via a login shell)
# pick this up
echo PATH="$PATH" | sudo bash -c "cat >> /home/user/.pam_environment"

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
