{ lib, ... }:

{
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
}
