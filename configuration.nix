# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

let
  custom-astronaut = pkgs.sddm-astronaut.override {
    themeConfig = {
      FormPosition = "right";             # Shifts login box to the right
      Background = "${./login-video.mp4}"; # Embeds video from /etc/nixos/
    };
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_cachyos;

  networking.hostName = "MirkoInNIXOS"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Manila";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  boot.supportedFilesystems = [ "ntfs" ];
  
  fileSystems."/mnt/LinuxPart" = {
    device = "/dev/disk/by-uuid/015337c8-827b-452d-aa39-74d2745d95c5";
    fsType = "ext4";
  };
  fileSystems."/mnt/WindowsPart" = { 
    device = "/dev/disk/by-uuid/921072191072048F"; 
    fsType = "ntfs-3g"; 
    options = [ "rw" "uid=1000" "gid=100" "dmask=0022" "fmask=0022" ];
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Graphics and Nvidia Prime
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Wayland / NVIDIA Environment Variables
  environment.sessionVariables = {
    # Force Wayland for GTK/Qt/Electron
    NIXOS_OZONE_WL = "1";
    XDG_SESSION_TYPE = "wayland";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";

    # NVIDIA / EGL Hardware Acceleration
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NVD_BACKEND = "direct";
  };

  # Display Environment
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "${custom-astronaut}/share/sddm/themes/sddm-astronaut-theme";

    # Remember the last logged-in user and desktop session
    settings = {
      Users = {
        RememberLastUser = true;
        RememberLastSession = true;
      };
    };

    extraPackages = with pkgs; [
      custom-astronaut
      kdePackages.qtsvg
      kdePackages.qtvirtualkeyboard
      kdePackages.qtmultimedia
    ];
  };

  services.desktopManager.plasma6.enable = true;

  # Set defaultSession
  services.displayManager.defaultSession = lib.mkForce "plasma";

  # For Development
  virtualisation.podman.enable = true;
  virtualisation.containers.registries.search = [ "docker.io" ];

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable Samba service and set up shares
  services.samba = {
    enable = true;
    openFirewall = true; # Automatically opens ports in the firewall for Samba
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "MirkoInNIXOS Samba Server";
        "netbios name" = "MirkoInNIXOS";
        "security" = "user";
        "guest account" = "nobody";
        "map to guest" = "Bad User";
      };
      
      # Example of a shared folder (repeat or create as many as you need)
      "Anime" = {
        "path" = "/mnt/LinuxPart/Anime/"; # Change this to your target shared directory path
        "browseable" = "yes";
        "read only" = "no"; # Local write control; restricted by user permissions below
        "guest ok" = "no";
        "valid users" = "@wheel, sambaro"; # Allow admin group and our specific read-only user
        "read list" = "sambaro";
      };
      
      "Movies" = {
        "path" = "/mnt/LinuxPart/Movies/"; # Change this to your target shared directory path
        "browseable" = "yes";
        "read only" = "no"; # Local write control; restricted by user permissions below
        "guest ok" = "no";
        "valid users" = "@wheel, sambaro"; # Allow admin group and our specific read-only user
        "read list" = "sambaro";
      };

      "Transfer" = {
        "path" = "/mnt/LinuxPart/Transfer/"; # Change this to your target shared directory path
        "browseable" = "yes";
        "read only" = "no"; # Local write control; restricted by user permissions below
        "guest ok" = "no";
        "valid users" = "@wheel, sambaro"; # Allow admin group and our specific read-only user
        "read list" = "sambaro";
      };
    };
  };

  # Optional: Enable WS-Discovery so Windows network discovery finds your shares automatically
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
  
  # Enable Avahi for mDNS / DNS-SD discovery (Mac, Linux, and local hostname resolution)
  services.avahi = {
    enable = true;
    nssmdns4 = true; # Enables name resolution for .local domains
    openFirewall = true; # Automatically opens the necessary UDP port 5353
  };

  # RealtimeKit is needed for PipeWire to acquire real-time priority.
  # This is what gives you that ultra-low latency for gaming.
  security.rtkit.enable = true; 
  
  services.pipewire = {
    enable = true;
    
    # ALSA is the lowest-level Linux sound architecture. 
    # Enabling 32-bit support is mandatory because many older Steam games are 32-bit.
    alsa.enable = true;
    alsa.support32Bit = true; 
    
    # THIS is the magic line. It enables the PulseAudio server emulation.
    # It gives you PulseAudio's stability and compatibility, powered by PipeWire.
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  users.users.mirkolouis = {
    isNormalUser = true;
    description = "mirkolouis";
    extraGroups = [ "networkmanager" "wheel" ]; 
  };

  users.users.sambaro = {
    isSystemUser = true;
    group = "nogroup";
    description = "Samba Read-Only User";
  };
  
  #Fonts
  fonts.packages = with pkgs; [
    # Nerd Fonts
    nerd-fonts.meslo-lg
    nerd-fonts.inconsolata
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono

    inter
    gelasio
    open-sans 
    rubik
 
    corefonts    # Microsoft Core Fonts
    vista-fonts  # Fonts from Vista
  ];

  #Programs
  programs.firefox.enable = true;
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; 
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true; # Highly recommended for Wayland compositor gaming
  };
  programs.appimage = {
    enable = true;
    binfmt = true;
  };  
  
  services.flatpak.enable = true;
  
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    distrobox
    wget
    git
    nomacs
    fastfetch
    kitty
    
    # Game Launchers & Managers
    heroic       # Open-source Epic/GOG launcher
    lutris       # Universal game manager
    bottles      # Wine/Proton prefix manager
    protonup-qt  # Added for GE-Proton management
    mangohud     # Performance Overlay

    # KDE
    kdePackages.dolphin
    kdePackages.kate
    kdePackages.ark
    kdePackages.okular
    kdePackages.kfind
    kdePackages.filelight
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}
