{ ... }:

{
  # Samba file shares (accessible to @wheel group and sambaro read-only user;
  # Backup share is for @wheel and the sambawo backup user)
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup"     = "WORKGROUP";
        "server string" = "MirkoInNIXOS Samba Server";
        "netbios name"  = "MirkoInNIXOS";
        "security"      = "user";
      };
      "Anime" = {
        "path"        = "/mnt/LinuxPart/Anime/";
        "browseable"  = "yes";
        "read only"   = "no";
        "guest ok"    = "no";
        "valid users" = "@wheel, sambaro";
        "read list"   = "sambaro";
      };
      "Movies" = {
        "path"        = "/mnt/LinuxPart/Movies/";
        "browseable"  = "yes";
        "read only"   = "no";
        "guest ok"    = "no";
        "valid users" = "@wheel, sambaro";
        "read list"   = "sambaro";
      };
      "Transfer" = {
        "path"        = "/mnt/LinuxPart/Transfer/";
        "browseable"  = "yes";
        "read only"   = "no";
        "guest ok"    = "no";
        "valid users" = "@wheel, sambaro";
        "read list"   = "sambaro";
      };
      "Backup" = {
        "path"           = "/mnt/LinuxPart/Backup/";
        "browseable"     = "yes";
        "read only"      = "no";
        "guest ok"       = "no";
        "valid users"    = "@wheel, sambawo";
        "force user"     = "mirkolouis";
        "force group"    = "users";
        "create mask"    = "0644";
        "directory mask" = "0755";
      };
    };
  };

  # WS-Discovery — lets Windows auto-discover Samba shares on the network
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  # Avahi mDNS — .local hostname resolution for Mac/Linux clients
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      userServices = true;
    };
  };
  
  # Run Samba only at home (home Wi-Fi by name, home ethernet by router MAC)
  # networking.networkmanager.dispatcherScripts = [{
  #   type = "basic";
  #   source = pkgs.writeShellScript "samba-home-only" ''
  #     [ "$2" = "up" ] || exit 0
  #     home=no
  #
  #     # Wi-Fi: match by connection name
  #     case "$CONNECTION_ID" in
  #       "YourHomeWiFi"|"YourHomeWiFi5G") home=yes ;;
  #     esac
  #
  #     # Ethernet: match by the router's MAC address
  #     if [ "$DEVICE_IFACE" = "enp2s0" ] && [ -n "$IP4_GATEWAY" ]; then
  #       ${pkgs.iputils}/bin/ping -c1 -W1 "$IP4_GATEWAY" >/dev/null 2>&1
  #       gwmac=$(${pkgs.iproute2}/bin/ip neigh show "$IP4_GATEWAY" | ${pkgs.gawk}/bin/awk '{print $5}')
  #       [ "$gwmac" = "e0:21:fe:17:c8:b0" ] && home=yes
  #     fi
  #
  #     if [ "$home" = yes ]; then
  #       ${pkgs.systemd}/bin/systemctl start samba.target
  #     else
  #       ${pkgs.systemd}/bin/systemctl stop samba.target
  #     fi
  #   '';
  # }];

  # ── Samba-only users (no login; password set with `sudo smbpasswd -a`) ────
  users.users.sambaro = {
    isSystemUser = true;
    group        = "nogroup";
    description  = "Samba Read-Only User";
  };

  users.users.sambawo = {
    isSystemUser = true;
    group        = "nogroup";
    description  = "Samba Backup User";
  };
}
