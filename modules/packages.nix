{ pkgs, ... }:

{
  # ── System Packages ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # Core utilities
    distrobox	# Distro Virtualization
    distroshelf	# GUI for distrobox
    wget	# for downloading from internet
    git		# for github
    killall	# kill but everyone
    nomacs	# Photo Viewer
    fastfetch	# ofcourse
    kitty	# Terminal
    clamav	# Open Source Antivirus
    nautilus	# File Manager
    ffmpeg	# Dependency for Nautilus
    ffmpegthumbnailer # Dependency for Nautilus
    totem 	# Dependency for Nautilus
    gst_all_1.gstreamer # Dependency for Nautilus
    gnome-text-editor  # Text Editor
    gnome-disk-utility # Disks GUI
    evince	# PDF Viewer
    bazaar	# Flatpak Store
    wineWow64Packages.waylandFull	#wine
    cliamp	# Terminal Music Player
    krita	# Photo Editor
    scribus	# Indesign Native Alternative
    unrar	# for .rar support
    p7zip	# archive library
    arj		# archive library?
    zstd	# archive library?
    lzop	# archive library
    lrzip	# archive library
    libnotify	# send notification via notify-send
    handbrake	# all-around media transcoder
    apostrophe	# md file viewer
    librewolf	# firefox fork
    tailscale	# expanding lan to internet?
    brave	# the one and only brave browser
    libimobiledevice	# for usb tethering
    proton-vpn 	# free VPN

    # Heker
    nmap	# network mapping
    wireshark	# network protocol analyzer

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
    hyprshot	# hyprland screenshotter
    grim	# for all screens screenshot support
    hyprviz	# gui way to setup hyprland
    hyprpolkitagent	# for apps to request sudo acess
    wallust	# another color picker
    cliphist		# for clipboard menu
    wl-clipboard	# for clipboard menu
    wlogout	# logout/shutdown/reboot menu

    # Gaming
    heroic      # Open-source Epic / GOG launcher
    lutris      # Universal game manager
    protonup-qt # GE-Proton version manager
    mangohud    # In-game performance overlay
    bottles	# another game manager
    protontricks	# a gui for winetricks
    winetricks	# provides a cli to tweak wine prefixes

    # KDE applications
    kdePackages.dolphin
    kdePackages.kate
    kdePackages.ark
    kdePackages.okular
    kdePackages.kfind
    kdePackages.filelight
    kdePackages.kamoso
  ];

  # ── Programs (packages that need a NixOS module) ───────────────────────────
  programs.firefox.enable   = true;
  programs.fish.enable      = true;
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

  programs.localsend = {
    enable = true;
    openFirewall = true;
  };

  # Programs that need SUID wrappers or run in user sessions
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
}
