{ ... }:

{
  time.timeZone = "Asia/Manila";

  # System locale — ensures proper UTF-8 encoding across all programs
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11 (uncomment to override)
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # TTY / virtual console settings
  # Note: TTY fonts must be PSF (bitmap) format — TTF fonts like Nerd Fonts
  # cannot be used here. Terminus is the best-looking monospaced PSF option.
  #console = {
    #earlySetup = true;    # Apply font from the very first boot message
    #font = "ter-v24n";    # Terminus 32px — clean and sharp on modern displays
    #keyMap = "us";
    #packages = [ pkgs.terminus_font ];
  #};
}
