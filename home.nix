{ config, pkgs, inputs, ... }:

{
  imports = [ 
    ./fish-db-functions.nix 
  ];

  home.username = "mirkolouis";
  home.homeDirectory = "/home/mirkolouis";
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Dracula";
      package = pkgs.dracula-theme;
    };
    gtk2.force = true;
    gtk4.theme = config.gtk.theme;
  };

  # Force Home Manager to overwrite GTK files modified by KDE Plasma
  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;

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

      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty-{kitty_pid}.sock";
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

  services.udiskie = {
    enable = true;
    notify = true;      # Enables notify-send popups through Dunst
    automount = true;   # Automatically mounts the drive so it appears in Nautilus instantly
  };

  xdg.configFile."fish/conf.d/custom_init.fish".text = ''
    if not set -q CONTAINER_ID
        fish_add_path /home/mirkolouis/.local/bin

        # ── NixOS rebuild + auto commit/push ────────────────────────────────
        function __nixos_rebuild
            git -C /etc/nixos add .
            and sudo nixos-rebuild switch --flake /etc/nixos/#MirkoInNIXOS
        end

        # usage: __nixos_commit_push <default message> [message from user]
        function __nixos_commit_push
            set -l repo /etc/nixos
            git -C $repo add .
            if git -C $repo diff --cached --quiet
                echo "No config changes to commit."
                return 0
            end
            echo
            git -C $repo status --short
            set -l msg $argv[2]
            if test -z "$msg"
                read -P "Commit message (Enter = \"$argv[1]\"): " msg
            end
            test -z "$msg"; and set msg $argv[1]
            git -C $repo commit -m "$msg"
            and git -C $repo push
        end

        function nixos-update --description "Rebuild, then commit & push /etc/nixos"
            __nixos_rebuild; or return 1
            __nixos_commit_push "update "(date '+%Y-%m-%d %H:%M') (string join " " $argv)
        end

        function nixos-upgrade --description "Update all flake inputs, rebuild, commit & push"
            nix flake update --flake /etc/nixos; or return 1
            __nixos_rebuild; or return 1
            __nixos_commit_push "flake update "(date +%Y-%m-%d) (string join " " $argv)
        end

        function nixos-upgrade-safe --description "Update nixpkgs + home-manager only, rebuild, commit & push"
            nix flake update nixpkgs home-manager --flake /etc/nixos; or return 1
            __nixos_rebuild; or return 1
            __nixos_commit_push "flake update (safe) "(date +%Y-%m-%d) (string join " " $argv)
        end

        alias nixos-bios="systemctl reboot --firmware-setup"
        alias nixos-cleanup="sudo nix-collect-garbage --delete-older-than 7d"
        alias nixos-optimize="sudo nix store optimise"
    end

    alias codium="codium --password-store=basic"

    if status is-interactive
        set -g fish_greeting
    end

    # History expansion (sudo !!)
    function last_history_item
        echo $history[1]
    end
    abbr -a !! --position anywhere --function last_history_item
  '';

  xdg.configFile."wlogout/layout".text = ''
    {
        "label" : "suspend",
        "action" : "systemctl suspend",
        "text" : "Suspend",
        "keybind" : "u"
    }
    {
        "label" : "logout",
        "action" : "hyprctl dispatch exit",
        "text" : "Logout",
        "keybind" : "e"
    }
    {
        "label" : "shutdown",
        "action" : "systemctl poweroff",
        "text" : "Shutdown",
        "keybind" : "s"
    }
    {
        "label" : "reboot",
        "action" : "systemctl reboot",
        "text" : "Reboot",
        "keybind" : "r"
    }
  '';

  xdg.configFile."electron-flags.conf".text = ''
    --enable-features=UseOzonePlatform
    --ozone-platform=wayland
  '';

  home.sessionVariables = {
    BUN_INSTALL = "/home/mirkolouis/.bun";
    NIXOS_OZONE_WL = "1";
    GTK_USE_PORTAL = "1";
    GTK_THEME = "Dracula";
  };
  
  home.sessionPath = [
    "/home/mirkolouis/.local/bin"
    "/home/mirkolouis/.bun/bin"
  ];
}
