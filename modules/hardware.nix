{ ... }:

{
  hardware.enableAllFirmware = true;

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
}
