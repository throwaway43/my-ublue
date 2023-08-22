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

# Enable kernel arguments
kargs:
  rpm-ostree kargs --append="amdgpu.ppfeaturemask=0xffffffff" --append="rd.luks.options=discard" --append="spectre_v2=on spec_store_bypass_disable=on" --append="l1tf=full,force" --append="mds=full" --append="tsx=off" --append="tsx_async_abort=full" --append="kvm.nx_huge_pages=force" --append="l1d_flush=on" --append="mmio_stale_data=full" --append="slab_nomerge" --append="init_on_alloc=1" --append="init_on_free=1" --append="pti=on" --append="vsyscall=none" --append="page_alloc.shuffle=1" --append="randomize_kstack_offset=on" --append="extra_latent_entropy" --append="debugfs=off" --append="oops=panic" --append="quiet" --append="loglevel=0" --append="random.trust_cpu=off" --append="random.trust_bootloader=off" --append="intel_iommu=on" --append="amd_iommu=on" --append="iommu.passthrough=0" --append="iommu.strict=1"

# Switch to the zsh shell
zsh:
  sudo lchsh $USER /usr/bin/zsh

# Setting up essentials on first-boot
first-boot:
  sudo btrfs subvolume snapshot -r /var/home /var/home/.snapshots/home-1
  sudo ostree admin pin 0

# Setting up ZSH Quickstart Kit and the necessary font
zsh-qsk:
  git clone https://github.com/jandamm/zgenom.git $HOME/zgenom
  git clone https://github.com/unixorn/zsh-quickstart-kit.git $HOME/zsh-quickstart-kit
  wget -O $HOME/.local/share/fonts/'MesloLGS NF'/'MesloLGS NF Regular.ttf' https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
  wget -O $HOME/.local/share/fonts/'MesloLGS NF'/'MesloLGS NF Bold.ttf' https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
  wget -O $HOME/.local/share/fonts/'MesloLGS NF'/'MesloLGS NF Italic.ttf' https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
  wget -O $HOME/.local/share/fonts/'MesloLGS NF'/'MesloLGS NF Bold Italic.ttf' https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
  gsettings set org.gnome.desktop.interface monospace-font-name 'MesloLGS NF 10'
  stow --dir=$HOME/zsh-quickstart-kit --target="$HOME" zsh
  wget -O $HOME/.p10k.zsh https://raw.githubusercontent.com/throwaway43/dotfiles/main/.p10k.zsh
  printf "Run:\nzqs disable-ssh-key-listing\nzqs disable-ssh-key-loading\n"

# Setting up aliases for ZSH
zsh-alias:
  echo "alias sudo=doas" > $HOME/.zshrc.d/001-doas
  echo "alias ls=lsd" > $HOME/.zshrc.d/002-lsd
  echo "alias cat=bat" > $HOME/.zshrc.d/003-bat
  echo 'eval "$(zoxide init zsh)"' > $HOME/.zshrc.d/004-zoxide-setup
  printf "Run:\nsource $HOME/.zshrc\n"

# Networkmanager trackability reduction
nm-track-reduc:
  sudo nmcli general reload conf
  sudo systemctl restart NetworkManager
  sudo hostnamectl hostname "localhost"
  sudo chown root:root /etc/NetworkManager/dispatcher.d/no-wait.d/01-no-send-hostname.sh
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

# USBGuard - LET OP! Dit keer diende /var/log/usbguard/usbguard-audit.log getouchd te worden (wss was ook het verwijderen dus zinloos), ook de directory waar de log in zat*
usbguard:
  usbguard generate-policy > $HOME/rules.conf
  sudo install -m 0600 -o root -g root $HOME/rules.conf /etc/usbguard/rules.conf
  rm $HOME/rules.conf
  sudo rm -f /var/log/usbguard/usbguard-audit.log
  systemctl start usbguard-dbus.service
  systemctl enable usbguard-dbus.service
  gsettings set org.gnome.desktop.privacy usb-protection true
  gsettings set org.gnome.desktop.privacy usb-protection-level always

# Storage Media Handling
udisks:
  echo '[org/gnome/desktop/media-handling]' | sudo tee /etc/dconf/db/local.d/automount-disable
  echo 'automount=false' | sudo tee -a /etc/dconf/db/local.d/automount-disable
  echo 'automount-open=false' | sudo tee -a /etc/dconf/db/local.d/automount-disable
  echo 'org/gnome/desktop/media-handling/automount' | sudo tee /etc/dconf/db/local.d/locks/automount-disable
  echo 'org/gnome/desktop/media-handling/automount-open' | sudo tee /etc/dconf/db/local.d/locks/automount-disable
  sudo dconf update

# Take away the Flatpak Permissions for home and system by default
flatpak-permissions:
  flatpak override --user --nofilesystem=home
  flatpak override --user --nofilesystem=host

# Setup Auto-cpufreq (Step 1)
auto-cpufreq-1:
  git clone https://github.com/AdnanHodzic/auto-cpufreq.git $HOME/auto-cpufreq
  sudo $HOME/auto-cpufreq/auto-cpufreq-installer

# Setup Auto-cpufreq (Step 2)
auto-cpufreq-2:
  sudo auto-cpufreq --install
  sudo auto-cpufreq --force=powersave

# Recover home from snapshot
recover-home:
  sudo cp -pr /var/home/.snapshots/home-1/user /var/home/

# Change machine-id
machine-id:
  echo "b08dfa6083e7567a1921a715000001fb" | sudo tee /etc/machine-id /var/lib/dbus/machine-id

# Initialization for tldr:
tldr:
  tldr --update

# Configure GNOME to your liking
gsettings:
  gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true

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
# Export Steam, Lutris and Protontricks from the Bazzite-Arch distrobox
export-bazzite:
  distrobox-enter -n bazzite-arch -- '  distrobox-export --app steam'
  distrobox-enter -n bazzite-arch -- '  distrobox-export --app lutris'
  distrobox-enter -n bazzite-arch -- '  distrobox-export --app protontricks'
  distrobox-enter -n bazzite-arch -- '  mkdir -p ~/.steam'
  distrobox-enter -n bazzite-arch -- '  distrobox-export --bin /usr/bin/steamcmd --export-path ~/.steam'
  distrobox-enter -n bazzite-arch -- '  mv ~/.steam/steamcmd ~/.steam/steamcmd.sh'
