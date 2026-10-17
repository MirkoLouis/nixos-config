{ ... }:

{
  # Samba file shares (accessible to @wheel group and sambaro read-only user;
  # Backup share is for @wheel and the sambawo backup user)
  # Samba users themselves are defined in users.nix.
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup"     = "WORKGROUP";
        "server string" = "MirkoInNIXOS Samba Server";
        "netbios name"  = "MirkoInNIXOS";
        "security"      = "user";
        "guest account" = "nobody";
        "map to guest"  = "Bad User";
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
}
