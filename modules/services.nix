{ pkgs, ... }:

{
  services.clamav.updater.enable = true;

  services.gvfs.enable = true;     # Trash, MTP, network mounts in Nautilus
  services.udisks2.enable = true;  # Removable drive mounting

  services.flatpak.enable = true;

  # sched-ext CPU schedulers (CachyOS) — currently off
  services.scx.enable = false;

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
