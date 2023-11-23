#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

mkdir -p /etc/ublue-update.d
wget -O /etc/ublue-update.d/90-mozilla-gnome-themes-user-update.sh https://raw.githubusercontent.com/ublue-os/bazzite/main/system_files/desktop/silverblue/usr/etc/ublue-update.d/user/90-mozilla-gnome-themes-user-update.sh
sed -i 's|org.mozilla.firefox/.mozilla/firefox/|io.gitlab.librewolf-community/.librewolf/|g' /etc/ublue-update.d/90-mozilla-gnome-themes-user-update.sh
