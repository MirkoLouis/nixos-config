{ ... }:

{
  imports = [
    ./hardware-configuration.nix

    # ── Most edited ─────────────────────────────────────────────────────────
    ./modules/packages.nix        # environment.systemPackages + programs.*

    # ── Kernel, graphics & desktop ──────────────────────────────────────────
    ./modules/kernel-desktop.nix
    #   boot:     bootloader, lanzaboote, CachyOS kernel
    #   graphics: Intel + NVIDIA Prime offload
    #   desktop:  SDDM, Plasma, Hyprland, portals
    #   fonts

    # ── Network shares ──────────────────────────────────────────────────────
    ./modules/samba.nix           # shares, WSDD, Avahi

    # ── Virtualisation ──────────────────────────────────────────────────────
    ./modules/virtualisation.nix  # Podman, libvirt

    # ── Everything else ─────────────────────────────────────────────────────
    ./modules/system.nix
    #   nix:         flakes, garbage collection, unfree
    #   locale:      timezone, language, TTY console
    #   filesystems: extra mounts (LinuxPart, WindowsPart)
    #   memory:      zram, swapfile, vm sysctl tuning
    #   security:    sudo, kernel hardening, fwupd
    #   hardware:    bluetooth, firmware, udev rules
    #   audio:       PipeWire
    #   networking:  hostname, NetworkManager, Tailscale
    #   firewall:    open ports
    #   users
    #   services:    ClamAV, gvfs, udisks, flatpak, usbmuxd
  ];

  # ── System Version ─────────────────────────────────────────────────────────
  # This defines the first NixOS version installed on this machine.
  # Used to maintain compatibility with application data from older versions.
  # Do NOT change this value after the initial install — it does NOT control
  # which nixpkgs version you get. See: https://nixos.org/manual/nixos/stable/
  system.stateVersion = "26.05";
}
