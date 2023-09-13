#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

wget -P /usr/etc/sysctl.d https://raw.githubusercontent.com/ublue-os/bazzite/ea65371d3d867bdfe9ccc8528f31661bfc0728b7/system_files/desktop/shared/usr/lib/sysctl.d/30-networking.conf
