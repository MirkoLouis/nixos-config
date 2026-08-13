{ config, pkgs, inputs, ... }:

{
  home.username = "mirkolouis";
  home.homeDirectory = "/home/mirkolouis";

  # State version for Home Manager
  home.stateVersion = "24.05";

  # Install the actual binaries required by the 43PR dotfiles
  home.packages = with pkgs; [
    waybar
    rofi
    wlogout
    awww # commonly used in these rice setups for wallpapers, adjust if they use hyprpaper
    wl-clipboard # needed for copy/paste in Wayland
  ];

  # Symlink specific directories from the raw GitHub input to ~/.config
  xdg.configFile = {
    "hypr".source = "${inputs.dotfiles-43pr}/.config/hypr";
    "wlogout".source = "${inputs.dotfiles-43pr}/.config/wlogout";
    "rofi".source = "${inputs.dotfiles-43pr}/.config/rofi";
    "waybar".source = "${inputs.dotfiles-43pr}/.config/waybar";
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
