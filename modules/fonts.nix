{ pkgs, ... }:

{
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
