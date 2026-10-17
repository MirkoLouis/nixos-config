{ pkgs, ... }:

{
  users.users.mirkolouis = {
    isNormalUser = true;
    description  = "mirkolouis";
    extraGroups  = [ "networkmanager" "wheel" "libvirtd" "kvm" "wireshark" ];
    shell = pkgs.fish;
  };

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
