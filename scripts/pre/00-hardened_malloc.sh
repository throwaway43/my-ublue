#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

sudo wget -O /etc/yum.repos.d/divested-release.repo https://gitlab.com/divested/divested-release/-/raw/master/divested-release.repo\?ref_type\=heads && \        wget -O /etc/pki/rpm-gpg/RPM-GPG-KEY-divested https://gitlab.com/divested/divested-release/-/raw/master/RPM-GPG-KEY-divested?ref_type=heads && \
rpm-ostree install hardened_malloc && \
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/divested-release.repo
