!include /usr/share/ublue-os/just/bling.just

# Install all flatpaks defined in recipe.yml
a1-setup-flatpaks: && a1-zsh
  #!/usr/bin/env bash
  echo 'Installing flatpaks from the ublue recipe ...'
  flatpaks=$(yq -- '.firstboot.flatpaks[]' "/usr/share/ublue-os/recipe.yml")
  for pkg in $flatpaks; do \
      echo "Installing: ${pkg}" && \
      flatpak install --user --noninteractive flathub $pkg; \
  done

# Enable kernel arguments
a0-kargs:
  rpm-ostree kargs --append=ipv6.disable=1 --append="amdgpu.ppfeaturemask=0xffffffff" --append="rd.luks.options=discard" --append="spectre_v2=on spec_store_bypass_disable=on" --append="l1tf=full,force" --append="mds=full" --append="tsx=off" --append="tsx_async_abort=full" --append="kvm.nx_huge_pages=force" --append="l1d_flush=on" --append="mmio_stale_data=full" --append="slab_nomerge" --append="init_on_alloc=1" --append="init_on_free=1" --append="pti=on" --append="vsyscall=none" --append="page_alloc.shuffle=1" --append="randomize_kstack_offset=on" --append="extra_latent_entropy" --append="debugfs=off" --append="oops=panic" --append="quiet" --append="loglevel=0" --append="random.trust_cpu=off" --append="random.trust_bootloader=off" --append="intel_iommu=on" --append="amd_iommu=on" --append="iommu.passthrough=0" --append="iommu.strict=1"

# Switch to the zsh shell
a1-zsh: && a1-zsh-qsk
  sudo lchsh $USER /usr/bin/zsh

# Setting up essentials on first-boot
# first-boot:
# sudo mkdir /var/home/.snapshots
# sudo btrfs subvolume snapshot -r /var/home /var/home/.snapshots/home-1
# sudo btrfs subvolume snapshot -r /var/home /var/home/.snapshots/var-1
# sudo ostree admin pin 0

# Setting up ZSH Quickstart Kit and the necessary font
a1-zsh-qsk: && a1-zsh-alias
  git clone https://github.com/jandamm/zgenom.git $HOME/zgenom
  git clone https://github.com/unixorn/zsh-quickstart-kit.git $HOME/zsh-quickstart-kit
  mkdir $HOME/.local/share/fonts
  mkdir $HOME/.local/share/fonts/'MesloLGS NF'
  wget -O $HOME/.local/share/fonts/'MesloLGS NF'/'MesloLGS NF Regular.ttf' https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
  wget -O $HOME/.local/share/fonts/'MesloLGS NF'/'MesloLGS NF Bold.ttf' https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
  wget -O $HOME/.local/share/fonts/'MesloLGS NF'/'MesloLGS NF Italic.ttf' https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
  wget -O $HOME/.local/share/fonts/'MesloLGS NF'/'MesloLGS NF Bold Italic.ttf' https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
  gsettings set org.gnome.desktop.interface monospace-font-name 'MesloLGS NF 10'
  stow --dir=$HOME/zsh-quickstart-kit --target="$HOME" zsh
  wget -O $HOME/.p10k.zsh https://raw.githubusercontent.com/throwaway43/dotfiles/main/.p10k.zsh
  printf "Run:\nzqs disable-ssh-key-listing\nzqs disable-ssh-key-loading\n"

# Setting up aliases for ZSH
a1-zsh-alias: && a1-tldr
  echo "alias sudo=doas" > $HOME/.zshrc.d/001-doas
  echo "alias ls=lsd" > $HOME/.zshrc.d/002-lsd
  echo "alias cat=bat" > $HOME/.zshrc.d/003-bat
  echo "alias sudoedit=doasedit" > $HOME/.zshrc.d/005-doasedit
  echo 'eval "$(zoxide init zsh)"' > $HOME/.zshrc.d/004-zoxide-setup
  echo "alias just=just --unstable" > $HOME/.zshrc.d/006-just
  printf "Run:\nsource $HOME/.zshrc\n"

# Networkmanager trackability reduction
a0-nm-track-reduc: && a0-machine-id
  sudo nmcli general reload conf
  sudo systemctl restart NetworkManager
  sudo hostnamectl hostname "localhost"
  sudo chown root:root /etc/NetworkManager/dispatcher.d/no-wait.d/01-no-send-hostname.sh
  sudo chmod 744 /etc/NetworkManager/dispatcher.d/no-wait.d/01-no-send-hostname.sh
  sudo ln -s /etc/NetworkManager/dispatcher.d/no-wait.d/01-no-send-hostname.sh /etc/NetworkManager/dispatcher.d/

# Firewall
a0-firewall: && a0-kargs
  firewall-cmd --set-default-zone=drop
  firewall-cmd --add-protocol=ipv6-icmp --permanent
  firewall-cmd --add-service=dhcpv6-client --permanent

# PAM
a1-pam: && a1-udisks
  sudo authselect select minimal with-faillock without-nullok with-pamaccess

# USBGuard - LET OP! Dit keer diende /var/log/usbguard/usbguard-audit.log getouchd te worden (wss was ook het verwijderen dus zinloos), ook de directory waar de log in zat*
a1-usbguard: && a1-setup-flatpaks
  usbguard generate-policy > $HOME/rules.conf
  sudo install -m 0600 -o root -g root $HOME/rules.conf /etc/usbguard/rules.conf
  rm $HOME/rules.conf
  sudo rm -f /var/log/usbguard/usbguard-audit.log
  systemctl start usbguard-dbus.service
  systemctl enable usbguard-dbus.service
  gsettings set org.gnome.desktop.privacy usb-protection true
  gsettings set org.gnome.desktop.privacy usb-protection-level always

# Storage Media Handling
a1-udisks: && a1-usbguard
  echo '[org/gnome/desktop/media-handling]' | sudo tee /etc/dconf/db/local.d/automount-disable 1>/dev/null
  echo 'automount=false' | sudo tee -a /etc/dconf/db/local.d/automount-disable 1>/dev/null
  echo 'automount-open=false' | sudo tee -a /etc/dconf/db/local.d/automount-disable 1>/dev/null
  echo 'org/gnome/desktop/media-handling/automount' | sudo tee /etc/dconf/db/local.d/locks/automount-disable 1>/dev/null
  echo 'org/gnome/desktop/media-handling/automount-open' | sudo tee /etc/dconf/db/local.d/locks/automount-disable 1>/dev/null
  sudo dconf update

# Proper hardening of Flatpak permissions
a0-flatpak-harden: && a0-firewall
  rm -rf ~/.local/share/flatpak/overrides/{,.[^.],..?}*
  git clone https://github.com/throwaway43/kyst ~/.local/share/flatpak/overrides
  cp ~/.local/share/flatpak/exports/share/applications/io.freetubeapp.FreeTube.desktop ~/.local/share/applications/
  sed -i 's|io.freetubeapp.FreeTube @@u|io.freetubeapp.FreeTube --ozone-platform-hint=auto @@u|g' ~/.local/share/applications/io.freetubeapp.FreeTube.desktop

# Setup Auto-cpufreq (Step 1)
a1-auto-cpufreq-1: && a1-auto-cpufreq-2
  mkdir $HOME/acf
  wget -O $HOME/acf/v1.9.8.zip https://github.com/AdnanHodzic/auto-cpufreq/archive/refs/tags/v1.9.8.zip
  unzip -q $HOME/acf/v1.9.8.zip -d $HOME/acf/
  sudo $HOME/acf/auto-cpufreq-1.9.8/auto-cpufreq-installer

# Setup Auto-cpufreq (Step 2)
a1-auto-cpufreq-2: && a1-install-brave
  sudo auto-cpufreq --install
  sudo auto-cpufreq --force=powersave
  sudo rm -rf $HOME/acf

# Recover home from snapshot
recover-home:
  sudo cp -pr /var/home/.snapshots/home-1/user /var/home/

# Change machine-id
a0-machine-id: && a0-flatpak-harden
  echo "b08dfa6083e7567a1921a715000001fb" | sudo tee /etc/machine-id /var/lib/dbus/machine-id 1>/dev/null

# Initialization for tldr:
a1-tldr: && a1-auto-cpufreq-1
  tldr --update

# Configure GNOME to your liking
a1-gsettings:
  gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true

# Turn off the extension version validation
ext-val-off:
  gsettings set org.gnome.shell disable-extension-version-validation true

# Turn on the extension version validation:
ext-val-on:
  gsettings set org.gnome.shell disable-extension-version-validation false

hide-grub:
  #!/usr/bin/env bash  
  sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/g' /etc/default/grub
  echo 'GRUB_TIMEOUT_STYLE=hidden' | sudo tee -a /etc/default/grub 1>/dev/null
  echo 'GRUB_HIDDEN_TIMEOUT=3' | sudo tee -a /etc/default/grub 1>/dev/null
  if [ -f '/boot/efi/EFI/fedora/grub.cfg' ]; then
    sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
  else
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
  fi

unhide-grub:
  #!/usr/bin/env bash
  sudo sed -i '/GRUB_HIDDEN_TIMEOUT=3/d' /etc/default/grub
  sudo sed -i '/GRUB_TIMEOUT_STYLE=hidden/d' /etc/default/grub
  sudo sed -i 's/GRUB_TIMEOUT=0/GRUB_TIMEOUT=5/g' /etc/default/grub
  if [ -f '/boot/efi/EFI/fedora/grub.cfg' ]; then
    sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
  else
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
  fi

# Install gamemode and export Steam, Lutris and Protontricks from the Bazzite-Arch distrobox
export-bazzite:
  distrobox-enter -n bazzite-arch -- '  distrobox-export --app steam'
  distrobox-enter -n bazzite-arch -- '  distrobox-export --app lutris'
  distrobox-enter -n bazzite-arch -- '  distrobox-export --app protontricks'
  distrobox-enter -n bazzite-arch -- '  mkdir -p ~/.steam'
  distrobox-enter -n bazzite-arch -- '  distrobox-export --bin /usr/bin/steamcmd --export-path ~/.steam'
  distrobox-enter -n bazzite-arch -- '  mv ~/.steam/steamcmd ~/.steam/steamcmd.sh'

# Disable steamwebhelpers from opening again and killing them afterwards:
steam-off:
  chmod a-x $HOME/.local/share/Steam/ubuntu12_64/steamwebhelper
  killall steamwebhelper

# Enable steamwebhelpers to open again
steam-on:
  chmod a+x $HOME/.local/share/Steam/ubuntu12_64/steamwebhelper

# Install Brave natively
a1-install-brave:
  sudo wget -O /etc/yum.repos.d/brave-browser.repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
  echo "repo_gpgcheck=1" | sudo tee -a /etc/yum.repos.d/brave-browser.repo 1>/dev/null
  echo "type=rpm" | sudo tee -a /etc/yum.repos.d/brave-browser.repo 1>/dev/null
  echo "gpgcheck=1" | sudo tee -a /etc/yum.repos.d/brave-browser.repo 1>/dev/null
  echo "gpgkey=file:///etc/pki/rpm-gpg/brave-core.asc" | sudo tee -a /etc/yum.repos.d/brave-browser.repo 1>/dev/null
  sudo wget -O /etc/pki/rpm-gpg/brave-core.asc https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
  rpm-ostree install brave-browser brave-keyring

# Harden /etc/fstab
a1-harden-fstab: && a1-bazzite-fstab
  sudo sed -i 's@defaults@defaults,nodev,noexec,nosuid@g' /etc/fstab
  sudo sed -i 's@shortname=winnt@shortname=winnt,nodev,noexec,nosuid@g' /etc/fstab
  sudo sed -i 's@subvol=home@subvol=home,nodev,nosuid@g' /etc/fstab

# Does all of the recipes with the a0- prefix
a0-setup: && a0-nm-track-reduc
  echo 'Hello, World!'

# Does all of the recipes with the a1- prefix
a1-setup: && a1-harden-fstab
  echo 'Almost done!'

# Enable DNSSEC
a1-dnssec: && a1-pam
  sudo sed -i 's/#DNSSEC=no/DNSSEC=yes/g' /etc/systemd/resolved.conf
  systemctl restart systemd-resolved

# Bazzite's fstab config
a1-bazzite-fstab: && a1-dnssec
  sudo sed -i 's/compress=zstd:1/noatime,lazytime,commit=120,discard=async,compress-force=zstd:1,space_cache=v2/g' /etc/fstab
