#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

wget -O /etc/yum.repos.d/brave-browser.repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
echo 'gpgkey=https://brave-browser-rpm-release.s3.brave.com/brave-core.asc' | tee -a /etc/yum.repos.d/brave-browser.repo 1>/dev/null
rpm-ostree install brave-keyring brave-browser
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/brave-browser.repo
