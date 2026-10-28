{ lib, pkgs, ... }:

{
  # ══ Nix (was nix.nix) ═══════════════════════════════════════════════════════

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d"; # Auto-delete generations older than 7 days
  };

  nix.optimise.automatic = true;   # weekly dedup of /nix/store

  nixpkgs.config.allowUnfree = true;

  # Copy config to /run/current-system/configuration.nix (useful as a backup)
  # system.copySystemConfiguration = true;

  # ══ Locale (was locale.nix) ═════════════════════════════════════════════════

  time.timeZone = "Asia/Manila";

  # System locale — ensures proper UTF-8 encoding across all programs
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11 (uncomment to override)
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # TTY / virtual console settings
  # Note: TTY fonts must be PSF (bitmap) format — TTF fonts like Nerd Fonts
  # cannot be used here. Terminus is the best-looking monospaced PSF option.
  #console = {
    #earlySetup = true;    # Apply font from the very first boot message
    #font = "ter-v24n";    # Terminus 32px — clean and sharp on modern displays
    #keyMap = "us";
    #packages = [ pkgs.terminus_font ];
  #};

  # ══ Filesystems (was filesystems.nix) ═══════════════════════════════════════

  fileSystems."/mnt/LinuxPart" = {
    device = "/dev/disk/by-uuid/015337c8-827b-452d-aa39-74d2745d95c5";
    fsType = "ext4";
    options = [ "nofail" "noauto" "x-systemd.automount" ];
  };

  fileSystems."/mnt/WindowsPart" = {
    device = "/dev/disk/by-uuid/921072191072048F";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "gid=100" "dmask=0022" "fmask=0022" "nofail" "noauto" "x-systemd.automount" ];
  };

  # ══ Memory (was memory.nix) ═════════════════════════════════════════════════

  # ── Swap & Memory Management (Gaming Optimized) ────────────────────────────

  # 1. High-Priority In-Memory Compressed Swap
  zramSwap = {
    enable = true;
    priority = 100;
    memoryPercent = 50;  # Allows up to 8GB of your RAM to be used for compression
    algorithm = "lz4";  # Zstandard offers the best compression-to-CPU-cost ratio
  };

  # 2. Low-Priority Physical Swapfile on NVMe Root (/)
  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;      # 8 GB allocated on the NVMe
      priority = 10;    # Only used if zRAM is completely exhausted
    }
  ];

  # 3. Kernel Tuning for zRAM and Gaming Responsiveness
  boot.kernel.sysctl = {
    "vm.swappiness" = 150;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };

  # ══ Security (was security.nix) ═════════════════════════════════════════════

  # Only members of wheel can even execute sudo
  security.sudo.execWheelOnly = true;

  # Hide kernel pointers and kernel logs from non-root users
  boot.kernel.sysctl = {
    "kernel.kptr_restrict"  = 2;
    "kernel.dmesg_restrict" = 1;
  };

  # Firmware updates (run `fwupdmgr refresh && fwupdmgr get-updates`)
  services.fwupd.enable = true;

  # ══ Hardware (was hardware.nix) ═════════════════════════════════════════════

  hardware.enableAllFirmware = true;
  services.thermald.enable = true;   # Intel thermal management

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  # For HE Keyboard to be recognized in Chromium Browsers
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1ca6", TAG+="uaccess"
  '';

  # Enable touchpad support (enabled by default in most desktopManagers)
  # services.libinput.enable = true;

  # ══ Audio (was audio.nix) ═══════════════════════════════════════════════════

  security.rtkit.enable = true; # Allows PipeWire to acquire real-time priority

  services.pipewire = {
    enable = true;
    alsa.enable        = true;
    alsa.support32Bit  = true; # Required for 32-bit Steam games
    pulse.enable       = true; # PulseAudio compatibility layer
  };

  # ══ Networking (was networking.nix) ═════════════════════════════════════════

  networking.hostName = "MirkoInNIXOS";

  networking.networkmanager = {
    enable = true;
    wifi.powersave = false;
    wifi.macAddress = "random";
  };

  # Tailscale — installed but not started on boot (start it manually)
  services.tailscale.enable = true;
  systemd.services.tailscaled.wantedBy = lib.mkForce [];

  # Enable the OpenSSH daemon
  # services.openssh.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # ══ Firewall (was firewall.nix) ═════════════════════════════════════════════

  # Ports for Samba, Avahi, Steam and LocalSend are opened by their own
  # modules (openFirewall = true). Only list extra ports here.
  networking.firewall = {
    enable = true;
    rejectPackets = false;
    allowedTCPPorts = [ 8000 3000 3050 3051 ];
    allowedUDPPorts = [];
  };

  # ══ Users (was users.nix) ═══════════════════════════════════════════════════

  users.users.mirkolouis = {
    isNormalUser = true;
    description  = "mirkolouis";
    extraGroups  = [ "networkmanager" "wheel" "libvirtd" "kvm" "wireshark" ];
    shell = pkgs.fish;
  };

  # ══ Services (was services.nix) ═════════════════════════════════════════════

  services.clamav.updater.enable = true;

  services.gvfs.enable = true;     # Trash, MTP, network mounts in Nautilus
  services.udisks2.enable = true;  # Removable drive mounting

  services.flatpak.enable = true;

  # ── iOS USB Tethering ──────────────────────────────────────────────────────
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };

  systemd.services.usbmuxd.serviceConfig = {
    TimeoutStopSec = "5s";
  };

  # Enable CUPS to print documents
  # services.printing.enable = true;
}
