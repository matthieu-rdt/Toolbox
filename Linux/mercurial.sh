#!/bin/bash

# description
# Script to install Mercurial under Debian & Ubuntu

username="$(whoami)"

sudo apt install mercurial mercurial-keyring python python3-pip -y

export PATH=$PATH:/home/$username/.local/bin

pip install --upgrade pip
pip install keyring==18.0.1
pip install mercurial_keyring
pip install keyrings.alt
