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

