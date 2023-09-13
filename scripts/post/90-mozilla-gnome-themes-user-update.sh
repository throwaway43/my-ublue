#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

mkdir -p /etc/ublue-update.d
wget -O /etc/ublue-update.d/90-mozilla-gnome-themes-user-update.sh https://raw.githubusercontent.com/ublue-os/bazzite/ddebbd3f2f761f1bd1c0dcae5b42902f5b91a2bf/system_files/desktop/silverblue/etc/ublue-update.d/90-mozilla-gnome-themes-user-update.sh
sed -i 's|org.mozilla.firefox/.mozilla/firefox/|io.gitlab.librewolf-community/.librewolf/|g' /etc/ublue-update.d/90-mozilla-gnome-themes-user-update.sh