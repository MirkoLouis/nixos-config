{ config, pkgs, inputs, ... }:

{
  imports = [ ./fish-db-functions.nix ];

  home.username = "mirkolouis";
  home.homeDirectory = "/home/mirkolouis";
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "/home/mirkolouis/Projects/frover.txt";
        type = "file";
        padding = {
          top = 2;
          left = 2;
        };
      };
      modules = [
        "title"
        "separator"
        "os"
        "host"
        "kernel"
        "uptime"
        "packages"
        "shell"
        "display"
        "de"
        "wm"
        "wmtheme"
        "theme"
        "icons"
        "font"
        "cursor"
        "terminal"
        "terminalfont"
        "cpu"
        "gpu"
        "memory"
        "swap"
        "disk"
        "localip"
        "locale"
        "break"
        "colors"
      ];
    };
  };

  programs.kitty = {
    enable = true;
    font = {
      name = "Inconsolata Nerd Font Mono";
      size = 12;
    };
    settings = {
      shell = "fish";
      # Cursor Customization
      cursor_trail = 3;
      cursor_trail_decay = "0.1 0.2";
      cursor_trail_start_threshold = 2;

      # Window Layout & QOL
      confirm_os_window_close = 0;
      window_padding_width = 8;
      remember_window_size = "no";
      initial_window_width = 1280;
      initial_window_height = 720;
      enable_audio_bell = "no";

      # Performance & Scrolling
      touch_scroll_multiplier = "1.0";
      wheel_scroll_multiplier = "5.0";
      sync_to_monitor = "yes";

      # Dracula Theme Configuration
      foreground = "#f8f8f2";
      background = "#282a36";
      selection_foreground = "#ffffff";
      selection_background = "#44475a";
      url_color = "#8be9fd";
      
      color0  = "#21222c";
      color8  = "#6272a4";
      color1  = "#ff5555";
      color9  = "#ff6e6e";
      color2  = "#50fa7b";
      color10 = "#69ff94";
      color3  = "#f1fa8c";
      color11 = "#ffffa5";
      color4  = "#bd93f9";
      color12 = "#d6acff";
      color5  = "#ff79c6";
      color13 = "#ff92df";
      color6  = "#8be9fd";
      color14 = "#a4ffff";
      color7  = "#f8f8f2";
      color15 = "#ffffff";
      
      cursor = "#f8f8f2";
      cursor_text_color = "background";
      
      active_tab_foreground = "#282a36";
      active_tab_background = "#f8f8f2";
      inactive_tab_foreground = "#282a36";
      inactive_tab_background = "#6272a4";
      
      mark1_foreground = "#282a36";
      mark1_background = "#ff5555";
      
      active_border_color = "#f8f8f2";
      inactive_border_color = "#6272a4";
    };
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        background = "#282a36";
        foreground = "#f8f8f2";
        frame_color = "#bd93f9"; 
        separator_color = "frame";
        separator_height = 11;
        font = "Inconsolata Nerd Font Mono 12";
        fullscreen = "pushback"; 
        follow = "keyboard"; 
      };

      urgency_low = {
        background = "#282a36";
        foreground = "#f8f8f2";
        frame_color = "#50fa7b";
        highlight = "#50fa7b";
        timeout = 4;
      };

      urgency_normal = {
        background = "#282a36";
        foreground = "#f8f8f2";
        frame_color = "#f1fa8c";
        highlight = "#f1fa8c";
        timeout = 6;
      };

      urgency_critical = {
        background = "#282a36";
        foreground = "#f8f8f2";
        frame_color = "#ff5555";
        highlight = "#ff5555";
        timeout = 0;
      };
    };
  };

  xdg.configFile."fish/conf.d/custom_init.fish".text = ''
    if status is-interactive
        set -g fish_greeting
    end

    # Custom NixOS aliases
    alias nixos-update="sudo git -C /etc/nixos add . && sudo nixos-rebuild switch --flake /etc/nixos/#MirkoInNIXOS"
    alias nixos-upgrade="sudo nix flake update --flake /etc/nixos && sudo git -C /etc/nixos add . && sudo nixos-rebuild switch --flake /etc/nixos/#MirkoInNIXOS"
    
    # Safely updates standard system packages while ignoring Chaotic-Nyx (kernel) updates
    alias nixos-upgrade-safe="sudo nix flake update nixpkgs home-manager --flake /etc/nixos && sudo git -C /etc/nixos add . && sudo nixos-rebuild switch --flake /etc/nixos/#MirkoInNIXOS"
    
    alias nixos-bios="systemctl reboot --firmware-setup"
    alias nixos-cleanup="sudo nix-collect-garbage --delete-older-than 7d"
    alias nixos-optimize="sudo nix store optimise"
  '';

  xdg.configFile."electron-flags.conf".text = ''
    --enable-features=UseOzonePlatform
    --ozone-platform=wayland
  '';

  home.sessionVariables = {
    BUN_INSTALL = "/home/mirkolouis/.bun";
    NIXOS_OZONE_WL = "1";
  };
  
  home.sessionPath = [
    "/home/mirkolouis/.local/bin"
    "/home/mirkolouis/.bun/bin"
  ];
}
