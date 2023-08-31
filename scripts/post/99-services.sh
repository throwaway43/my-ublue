
systemctl disable NetworkManager-wait-online.service && \
systemctl mask rpm-ostree-countme.timer && \
systemctl enable com.system76.Scheduler.service && \
systemctl enable bazzite-hardware-setup.service && \
systemctl unmask dconf-update.service && \
systemctl enable dconf-update.service
