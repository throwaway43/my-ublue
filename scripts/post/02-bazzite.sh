#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

wget -P /usr/etc/sysctl.d https://raw.githubusercontent.com/ublue-os/bazzite/main/system_files/desktop/shared/etc/sysctl.d/30-networking.conf && \
