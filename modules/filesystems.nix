{ ... }:

{
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
}
