{ ... }:

{
  imports = [
    ./hardware-configuration.nix

    # ── Most edited ─────────────────────────────────────────────────────────
    ./modules/packages.nix        # environment.systemPackages + programs.*

    # ── System ──────────────────────────────────────────────────────────────
    ./modules/nix.nix             # flakes, garbage collection, unfree
    ./modules/boot.nix            # bootloader, lanzaboote, CachyOS kernel
    ./modules/locale.nix          # timezone, language, TTY console
    ./modules/filesystems.nix     # extra mounts (LinuxPart, WindowsPart)
    ./modules/memory.nix          # zram, swapfile, vm sysctl tuning

    # ── Hardware ────────────────────────────────────────────────────────────
    ./modules/graphics.nix        # Intel + NVIDIA Prime offload
    ./modules/hardware.nix        # bluetooth, firmware, udev rules
    ./modules/audio.nix           # PipeWire

    # ── Network ─────────────────────────────────────────────────────────────
    ./modules/networking.nix      # hostname, NetworkManager, Tailscale
    ./modules/firewall.nix        # open ports
    ./modules/samba.nix           # shares, WSDD, Avahi

    # ── Desktop & users ─────────────────────────────────────────────────────
    ./modules/desktop.nix         # SDDM, Plasma, Hyprland, portals
    ./modules/fonts.nix
    ./modules/users.nix

    # ── Everything else ─────────────────────────────────────────────────────
    ./modules/virtualisation.nix  # Podman, libvirt
    ./modules/services.nix        # ClamAV, gvfs, udisks, flatpak, usbmuxd
  ];

  # ── System Version ─────────────────────────────────────────────────────────
  # This defines the first NixOS version installed on this machine.
  # Used to maintain compatibility with application data from older versions.
  # Do NOT change this value after the initial install — it does NOT control
  # which nixpkgs version you get. See: https://nixos.org/manual/nixos/stable/
  system.stateVersion = "26.05";
}
