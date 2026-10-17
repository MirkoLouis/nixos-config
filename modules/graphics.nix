{ pkgs, ... }:

{
  # NVIDIA Prime (Intel iGPU + NVIDIA dGPU hybrid graphics)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true; # Open source kernel module
    nvidiaSettings = true;
    package = pkgs.nvidia_cachyos;
    prime = {
      sync.enable = false;
      offload.enable = true;
      offload.enableOffloadCmd = true;
      intelBusId  = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    dynamicBoost.enable = true;
  };
}
