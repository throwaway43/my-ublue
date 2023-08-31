 && \
wget -P /usr/etc/sysctl.d https://raw.githubusercontent.com/ublue-os/bazzite/main/system_files/desktop/shared/etc/sysctl.d/30-networking.conf && \
wget -P /usr/bin/ https://raw.githubusercontent.com/ublue-os/bazzite/main/system_files/desktop/shared/usr/bin/bazzite-hardware-setup

wget -P /usr/etc https://raw.githubusercontent.com/GrapheneOS/infrastructure/main/chrony.conf

systemctl disable NetworkManager-wait-online.service && \
systemctl mask rpm-ostree-countme.timer && \
systemctl enable com.system76.Scheduler.service && \
systemctl enable bazzite-hardware-setup.service && \
systemctl unmask dconf-update.service && \
systemctl enable dconf-update.service
