!include /usr/share/ublue-os/just/bling.just

# Install all flatpaks defined in recipe.yml
setup-flatpaks:
  #!/usr/bin/env bash
  echo 'Installing flatpaks from the ublue recipe ...'
  flatpaks=$(yq -- '.firstboot.flatpaks[]' "/usr/share/ublue-os/recipe.yml")
  for pkg in $flatpaks; do \
      echo "Installing: ${pkg}" && \
      flatpak install --user --noninteractive flathub $pkg; \
  done

# Include some of your custom scripts here!

# Add boot parameters needed for a Framework 13 laptop
kargs:
  rpm-ostree kargs --append="rd.luks.options=discard" --append="spectre_v2=on spec_store_bypass_disable=on" --append="l1tf=full,force" --append="mds=full" --append="tsx=off" --append="tsx_async_abort=full" --append="kvm.nx_huge_pages=force" --append="l1d_flush=on" --append="mmio_stale_data=full" --append="slab_nomerge" --append="init_on_alloc=1" --append="init_on_free=1" --append="pti=on" --append="vsyscall=none" --append="page_alloc.shuffle=1" --append="randomize_kstack_offset=on" --append="extra_latent_entropy" --append="debugfs=off" --append="oops=panic" --append="quiet" --append="loglevel=0" --append="random.trust_cpu=off" --append="random.trust_bootloader=off" --append="intel_iommu=on" --append="amd_iommu=on" --append="iommu.passthrough=0" --append="iommu.strict=1"

# Switch to the zsh shell
zsh:
  sudo lchsh $USER /usr/bin/zsh

# Setting up essentials on first-boot
first-boot:
  sudo btrfs subvolume snapshot -r /var/home /var/home/.snapshots/home-1
  sudo ostree admin pin 0

# Setting up ZSH Quickstart Kit (step 1)
zshqsk1:
  git clone https://github.com/jandamm/zgenom.git $HOME/zgenom
  git clone https://github.com/unixorn/zsh-quickstart-kit.git $HOME/zsh-quickstart-kit
  stow --dir=$HOME/zsh-quickstart-kit --target="$HOME" zsh
  echo "Run the following command: 'source $HOME/.zshrc' "

# Setting up ZSH Quickstart Kit (step 2)
zshqsk2:
  zqs disable-ssh-key-listing
  zqs disable-ssh-key-loading
  p10k configure

# Networkmanager trackability reduction
nm-track-reduc:
  sudo nmcli general reload conf
  sudo systemctl restart NetworkManager
  sudo hostnamectl hostname "localhost"
  sudo cd /etc/NetworkManager/dispatcher.d/
  sudo chown root:root no-wait.d/01-no-send-hostname.sh
  sudo chmod 744 no-wait.d/01-no-send-hostname.sh
  sudo ln -s no-wait.d/01-no-send-hostname.sh ./

# Firewall
firewall:
  firewall-cmd --set-default-zone=drop
  firewall-cmd --add-protocol=ipv6-icmp --permanent
  firewall-cmd --add-service=dhcpv6-client --permanent

# PAM
pam:
  sudo authselect select minimal with-faillock without-nullok with-pamaccess

# USBGuard
usbguard:
  usbguard generate-policy > $HOME/rules.conf
  cd $HOME
  sudo install -m 0600 -o root -g root rules.conf /etc/usbguard/rules.conf
  systemctl start usbguard-dbus.service
  systemctl enable usbguard-dbus.service
  gsettings set org.gnome.desktop.privacy usb-protection true
  gsettings set org.gnome.desktop.privacy usb-protection-level always

# Storage Media Handling
udisks:
  echo '[org/gnome/desktop/media-handling]
  automount=false
  automount-open=false' | sudo tee /etc/dconf/db/local.d/automount-disable
  echo 'org/gnome/desktop/media-handling/automount
  org/gnome/desktop/media-handling/automount-open' | sudo tee /etc/dconf/db/local.d/locks/automount-disable
  sudo dconf update

# Take away the Flatpak Permissions for home and system by default
flatpak-permissions:
  flatpak override --user --nofilesystem=home
  flatpak override --user --nofilesystem=host

# Setup Auto-cpufreq
auto-cpufreq:
  git clone https://github.com/AdnanHodzic/auto-cpufreq.git $HOME/auto-cpufreq
  cd $HOME/auto-cpufreq && sudo ./auto-cpufreq-installer --install
  sudo auto-cpufreq --install
  sudo auto-cpufreq --force=powersave

# Recover home from snapshot
recover-home:
  sudo cp -pr /var/home/.snapshots/home-1/user /var/home/
