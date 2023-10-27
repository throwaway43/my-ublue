#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

wget -P /usr/etc/sysctl.d https://raw.githubusercontent.com/Kicksecure/security-misc/master/usr/lib/sysctl.d/990-security-misc.conf && \
wget -P /usr/etc/sysctl.d https://raw.githubusercontent.com/Kicksecure/security-misc/master/usr/lib/sysctl.d/30_security-misc_kexec-disable.conf && \
wget -P /usr/etc/sysctl.d https://raw.githubusercontent.com/Kicksecure/security-misc/master/usr/lib/sysctl.d/30_silent-kernel-printk.conf && \
wget -P /usr/etc/modprobe.d https://raw.githubusercontent.com/throwaway43/security-misc/master/etc/modprobe.d/30_security-misc.conf
