{ ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d"; # Auto-delete generations older than 7 days
  };

  nixpkgs.config.allowUnfree = true;

  # Copy config to /run/current-system/configuration.nix (useful as a backup)
  # system.copySystemConfiguration = true;
}
