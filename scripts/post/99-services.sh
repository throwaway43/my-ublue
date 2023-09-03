#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

systemctl disable NetworkManager-wait-online.service && \
systemctl mask rpm-ostree-countme.timer && \
systemctl enable com.system76.Scheduler.service
