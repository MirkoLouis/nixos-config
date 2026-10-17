{ ... }:

{
  hardware.enableAllFirmware = true;

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # For HE Keyboard to be recognized in Chromium Browsers
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", TAG+="uaccess"
  '';

  # Enable touchpad support (enabled by default in most desktopManagers)
  # services.libinput.enable = true;

  # systemd.services.unblock-bluetooth = {
  #   description = "Forcefully unblock Bluetooth on boot";
  #   wantedBy = [ "multi-user.target" ];
  #   # Wait for the built-in rfkill cache to finish restoring first
  #   after = [ "bluetooth.service" "systemd-rfkill.service" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     # Add a 3-second delay to guarantee all kernel modules have settled
  #     ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
  #     ExecStart = "${pkgs.util-linux}/bin/rfkill unblock bluetooth";
  #     RemainAfterExit = true;
  #   };
  # };
}
