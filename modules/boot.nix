{ lib, pkgs, ... }:

{
  # systemd-boot must stay OFF — lanzaboote (Secure Boot) replaces it below.
  #boot.loader.systemd-boot.enable = false;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    configurationLimit = 10;
  };

  # CachyOS kernel (from Chaotic-Nyx)
  boot.kernelPackages = pkgs.linuxPackages_cachyos.cachyOverride {
    cachyVars = pkgs.linuxPackages_cachyos-lts.kernel.cachyConfig.cachyVars // {
      "_processor_opt" = "GENERIC_V4";
    };
  };

  boot.kernelParams = [ "split_lock_detect=off" ];

  boot.supportedFilesystems = [ "ntfs" ];
}
