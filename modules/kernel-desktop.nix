{ lib, pkgs, ... }:

let
  # Paths are relative to this file, so the assets live one folder up (/etc/nixos)
  custom-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "japanese_aesthetic";
    themeConfig = {
      Font         = "MatrixType";
      FormPosition = "right";
      Background   = "${../login-video.mp4}";
      HourFormat   = "h:mm";
      DateFormat   = "dddd";

      HeaderTextColor                  = "#ffffff";
      DateTextColor                    = "#ffffff";
      TimeTextColor                    = "#ffffff";
      LoginFieldTextColor              = "#ffffff";
      PasswordFieldTextColor           = "#ffffff";
      UserIconColor                    = "#ffffff";
      PasswordIconColor                = "#ffffff";
      PlaceholderTextColor             = "#cccccc";
      WarningColor                     = "#ffffff";
      SystemButtonsIconsColor          = "#ffffff";
      SessionButtonTextColor           = "#ffffff";
      VirtualKeyboardButtonTextColor   = "#ffffff";
    };
  };
in

{
  # ══ Boot & kernel (was boot.nix) ════════════════════════════════════════════

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
  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  
  #boot.kernelPackages = pkgs.linuxPackages_cachyos.cachyOverride {
  #  cachyVars = pkgs.linuxPackages_cachyos-lts.kernel.cachyConfig.cachyVars // {
  #    "_processor_opt" = "GENERIC_V4";
  #  };
  #};

  boot.kernelParams = [ "split_lock_detect=off" ];

  boot.supportedFilesystems = [ "ntfs" ];

  # ══ CPU scheduler (was in services.nix) ═════════════════════════════════════

  # sched-ext CPU schedulers (CachyOS) — currently off
  services.scx.enable = false;

  # ══ Graphics (was graphics.nix) ═════════════════════════════════════════════

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
      finegrained = false;	# was true - allows for gpu to fully power down when idle
    };
    dynamicBoost.enable = false; # Did not work during testing
  };

  # ══ Desktop (was desktop.nix) ═══════════════════════════════════════════════

  # SDDM login manager with astronaut theme
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "${custom-astronaut}/share/sddm/themes/sddm-astronaut-theme";
    settings.Users = {
      RememberLastUser    = true;
      RememberLastSession = true;
    };
    extraPackages = with pkgs; [
      custom-astronaut
      kdePackages.qtsvg
      kdePackages.qtvirtualkeyboard
      kdePackages.qtmultimedia
    ];
  };

  # KDE Plasma 6 desktop (Wayland session)
  services.desktopManager.plasma6.enable = true;

  # Hyprland
  programs.hyprland.enable = true;

  xdg.portal = {
    config = {
      hyprland = {
        default = [ "gtk" "hyprland" ];
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
      };
    };
  };

  programs.dconf.enable = true;

  # ══ Fonts (was fonts.nix) ═══════════════════════════════════════════════════

  fonts.packages = with pkgs; [
    # Nerd Fonts (terminal / coding)
    nerd-fonts.meslo-lg
    nerd-fonts.inconsolata
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.ubuntu

    # General UI fonts
    inter
    gelasio
    open-sans
    rubik
    iosevka

    corefonts   # Microsoft Core Fonts
    vista-fonts # Fonts from Windows Vista

    # SDDM login font (file lives in /etc/nixos, one folder up)
    (runCommand "custom-sddm-font" {} ''
      mkdir -p $out/share/fonts/truetype
      cp ${../MatrixType-Regular.ttf} $out/share/fonts/truetype/
    '')
  ];
}
