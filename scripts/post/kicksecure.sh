#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

# Your code goes here.
echo 'This is an example shell script'
echo 'Scripts here will run during build if specified in recipe.yml'
# Cleanup & Finalize

RUN wget -P /usr/etc/sysctl.d https://raw.githubusercontent.com/Kicksecure/security-misc/master/etc/sysctl.d/30_security-misc.conf && \
    wget -P /usr/etc/sysctl.d https://raw.githubusercontent.com/Kicksecure/security-misc/master/etc/sysctl.d/30_security-misc_kexec-disable.conf && \
    wget -P /usr/etc/sysctl.d https://raw.githubusercontent.com/Kicksecure/security-misc/master/etc/sysctl.d/30_silent-kernel-printk.conf && \
    wget -P /usr/etc/modprobe.d https://raw.githubusercontent.com/throwaway43/security-misc/master/etc/modprobe.d/30_security-misc.conf && \
    wget -P /usr/etc/sysctl.d https://raw.githubusercontent.com/ublue-os/bazzite/main/system_files/desktop/shared/etc/sysctl.d/30-networking.conf && \
    wget -P /usr/bin/ https://raw.githubusercontent.com/ublue-os/bazzite/main/system_files/desktop/shared/usr/bin/bazzite-hardware-setup

RUN wget -P /usr/etc https://raw.githubusercontent.com/GrapheneOS/infrastructure/main/chrony.conf

RUN systemctl disable NetworkManager-wait-online.service && \
    systemctl mask rpm-ostree-countme.timer && \
    systemctl enable com.system76.Scheduler.service && \
    systemctl enable bazzite-hardware-setup.service && \
    systemctl unmask dconf-update.service && \
    systemctl enable dconf-update.service
