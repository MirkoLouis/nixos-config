{ config, lib, pkgs, inputs, ... }:

let
  custom-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "japanese_aesthetic";
    themeConfig = {
      Font         = "MatrixType";
      FormPosition = "right";
      Background   = "${./login-video.mp4}";
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
  imports = [ ./hardware-configuration.nix ];

  # ── Boot & Kernel ──────────────────────────────────────────────────────────
  #boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_cachyos-lts.cachyOverride {
    cachyVars = pkgs.linuxPackages_cachyos-lts.kernel.cachyConfig.cachyVars // { 
      "_processor_opt" = "GENERIC_V4"; 
    };
  };

  boot.kernelParams = [ "split_lock_detect=off" ];

  boot.supportedFilesystems = [ "ntfs" ];

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # ── Networking ─────────────────────────────────────────────────────────────
  networking.hostName = "MirkoInNIXOS";
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # ── Locale & Time ──────────────────────────────────────────────────────────
  time.timeZone = "Asia/Manila";

  # System locale — ensures proper UTF-8 encoding across all programs
  i18n.defaultLocale = "en_US.UTF-8";

  # TTY / virtual console settings
  # Note: TTY fonts must be PSF (bitmap) format — TTF fonts like Nerd Fonts
  # cannot be used here. Terminus is the best-looking monospaced PSF option.
  #console = {
    #earlySetup = true;    # Apply font from the very first boot message
    #font = "ter-v24n";    # Terminus 32px — clean and sharp on modern displays
    #keyMap = "us";
    #packages = [ pkgs.terminus_font ];
  #};

  # ── Nix Settings ───────────────────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d"; # Auto-delete generations older than 7 days
  };
  nixpkgs.config.allowUnfree = true;

  # ── Filesystems ────────────────────────────────────────────────────────────
  fileSystems."/mnt/LinuxPart" = {
    device = "/dev/disk/by-uuid/015337c8-827b-452d-aa39-74d2745d95c5";
    fsType = "ext4";
  };
  fileSystems."/mnt/WindowsPart" = {
    device = "/dev/disk/by-uuid/921072191072048F";
    fsType = "ntfs-3g";
    options = [ "rw" "uid=1000" "gid=100" "dmask=0022" "fmask=0022" ];
  };

  # ── Hardware ───────────────────────────────────────────────────────────────

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # NVIDIA Prime (Intel iGPU + NVIDIA dGPU hybrid graphics)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = pkgs.nvidia_cachyos-lts;
    prime = {
      sync.enable = false;
      offload.enable = true;
      offload.enableOffloadCmd = true;
      intelBusId  = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Configure keymap in X11 (uncomment to override)
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # ── Swap & Memory Management (Gaming Optimized) ────────────────────────────

  # 1. High-Priority In-Memory Compressed Swap
  zramSwap = {
    enable = true;
    priority = 100;
    memoryPercent = 50;  # Allows up to 8GB of your RAM to be used for compression
    algorithm = "zstd";  # Zstandard offers the best compression-to-CPU-cost ratio
  };

  # 2. Low-Priority Physical Swapfile on NVMe Root (/)
  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;      # 8 GB allocated on the NVMe
      priority = 10;    # Only used if zRAM is completely exhausted
    }
  ];

  # 3. Kernel Tuning for zRAM and Gaming Responsiveness
  boot.kernel.sysctl = {
    "vm.swappiness" = 100; 
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };

  # ── Display & Desktop ──────────────────────────────────────────────────────

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

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  # KDE Plasma 6 desktop (Wayland session)
  services.desktopManager.plasma6.enable = true;

  programs.hyprland.enable = true;

  # ── Audio ──────────────────────────────────────────────────────────────────
  security.rtkit.enable = true; # Allows PipeWire to acquire real-time priority
  services.pipewire = {
    enable = true;
    alsa.enable        = true;
    alsa.support32Bit  = true; # Required for 32-bit Steam games
    pulse.enable       = true; # PulseAudio compatibility layer
  };

  # ── Virtualisation ─────────────────────────────────────────────────────────
  virtualisation.podman.enable = true;
  virtualisation.containers.registries.search = [ "docker.io" ];

  # ── Network Sharing ────────────────────────────────────────────────────────

  # Samba file shares (accessible to @wheel group and sambaro read-only user)
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup"    = "WORKGROUP";
        "server string" = "MirkoInNIXOS Samba Server";
        "netbios name" = "MirkoInNIXOS";
        "security"     = "user";
        "guest account" = "nobody";
        "map to guest" = "Bad User";
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
  };

  # ── Users ──────────────────────────────────────────────────────────────────
  users.users.mirkolouis = {
    isNormalUser = true;
    description  = "mirkolouis";
    extraGroups  = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };

  users.users.sambaro = {
    isSystemUser = true;
    group        = "nogroup";
    description  = "Samba Read-Only User";
  };

  # ── Fonts ──────────────────────────────────────────────────────────────────
  fonts.packages = with pkgs; [
    # Nerd Fonts (terminal / coding)
    nerd-fonts.meslo-lg
    nerd-fonts.inconsolata
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.ubuntu
    nerd-fonts.jetbrains-mono

    # General UI fonts
    inter
    gelasio
    open-sans
    rubik
    iosevka

    corefonts   # Microsoft Core Fonts
    vista-fonts # Fonts from Windows Vista

    (runCommand "custom-sddm-font" {} ''
      mkdir -p $out/share/fonts/truetype
      cp ${./MatrixType-Regular.ttf} $out/share/fonts/truetype/
    '')
  ];

  # ── Programs ───────────────────────────────────────────────────────────────
  programs.firefox.enable   = true;
  programs.gamemode.enable  = true; # Boosts CPU/GPU performance on demand for games

  programs.steam = {
    enable                       = true;
    remotePlay.openFirewall      = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable      = true; # Wayland-native compositor for gaming
  };

  programs.appimage = {
    enable = true;
    binfmt = true; # Run AppImages directly without manual mounting
  };

  programs.fish.enable = true;

  services.flatpak.enable = true;

  # Programs that need SUID wrappers or run in user sessions
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # ── System Packages ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # Core utilities
    distrobox
    wget
    git
    killall
    nomacs
    fastfetch
    kitty
    clamav
    imagemagick
    nautilus
    ffmpeg
    ffmpegthumbnailer
    totem
    gst_all_1.gstreamer
    gnome-text-editor
    gnome-disk-utility
    evince
    bazaar
    wineWow64Packages.waylandFull
    cliamp
    gimp

    # Hyprland
    dunst	# notification daemon
    ashell	# status bar
    jq		# ashell dependency
    pavucontrol	# pulseaudio volume control gui
    pwvucontrol	# piprewire volume control gui
    overskride	# bluetooth manager
    networkmanagerapplet # gui for nmcli
    walker	# application launcher
    elephant	# walker's backend
    rofi	# frontend wallpaper switcher
    awww	# backend wallpaper switcher
    imagemagick # required for caching wallpapers
    hypridle	# hyprland idle?
    brightnessctl # cli for brightness

    # Game launchers & managers
    heroic      # Open-source Epic / GOG launcher
    lutris      # Universal game manager
    protonup-qt # GE-Proton version manager
    mangohud    # In-game performance overlay

    # KDE applications
    kdePackages.dolphin
    kdePackages.kate
    kdePackages.ark
    kdePackages.okular
    kdePackages.kfind
    kdePackages.filelight
  ];

  # ── Services ───────────────────────────────────────────────────────────────

  services.clamav.updater.enable = true;

  services.gvfs.enable = true;

  services.udisks2.enable = true;

  services.scx = {
    enable = true;
    scheduler = "scx_lavd";
  };

  # Enable the OpenSSH daemon
  # services.openssh.enable = true;

  # Open ports in the firewall
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether
  # networking.firewall.enable = false;

  # Enable CUPS to print documents
  # services.printing.enable = true;

  # Enable touchpad support (enabled by default in most desktopManagers)
  # services.libinput.enable = true;  # Enable CUPS to print documents
  # services.printing.enable = true;

  # Enable touchpad support (enabled by default in most desktopManagers)
  # services.libinput.enable = true;

  # Copy config to /run/current-system/configuration.nix (useful as a backup)
  # system.copySystemConfiguration = true;

  # ── System Version ─────────────────────────────────────────────────────────
  # This defines the first NixOS version installed on this machine.
  # Used to maintain compatibility with application data from older versions.
  # Do NOT change this value after the initial install — it does NOT control
  # which nixpkgs version you get. See: https://nixos.org/manual/nixos/stable/
  system.stateVersion = "26.05";
}
