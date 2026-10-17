{ ... }:

{
  # Only members of wheel can even execute sudo
  security.sudo.execWheelOnly = true;

  # Hide kernel pointers and kernel logs from non-root users
  boot.kernel.sysctl = {
    "kernel.kptr_restrict"  = 2;
    "kernel.dmesg_restrict" = 1;
  };

  # Firmware updates (run `fwupdmgr refresh && fwupdmgr get-updates`)
  services.fwupd.enable = true;
}
