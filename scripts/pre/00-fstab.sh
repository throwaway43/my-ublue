#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

sed -i 's@defaults@defaults,nodev,noexec,nosuid@g' /etc/fstab
sed -i 's@winnt@winnt,nodev,noexec,nosuid@g' /etc/fstab
