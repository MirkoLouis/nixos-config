{ ... }:

{
  # Ports for Samba, Avahi, Steam and LocalSend are opened by their own
  # modules (openFirewall = true). Only list extra ports here.
  networking.firewall = {
    enable = true;
    rejectPackets = false;
    allowedTCPPorts = [ 8000 3000 3050 3051 ];
    allowedUDPPorts = [];
  };
}
