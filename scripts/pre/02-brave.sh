#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

wget -O /etc/yum.repos.d/brave-browser.repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
#wget -O /etc/pki/rpm-gpg/brave.asc https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
echo 'gpgcheck=1' | tee -a /etc/yum.repos.d/brave-browser.repo 1>/dev/null
echo 'repo_gpgcheck=1' | tee -a /etc/yum.repos.d/brave-browser.repo 1>/dev/null
echo 'gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-brave' | tee -a /etc/yum.repos.d/brave-browser.repo 1>/dev/null
rpm-ostree install brave-keyring
rpm-ostree install brave-browser
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/brave-browser.repo
