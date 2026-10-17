{ pkgs, ... }:

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
}
