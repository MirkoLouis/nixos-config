{ pkgs, ... }:

{
  # ══ Containers & VMs ════════════════════════════════════════════════════════

  virtualisation.podman.enable = true;
  virtualisation.libvirtd.enable = true;

  virtualisation.containers.registries.settings = {
    unqualified-search-registries = [ "docker.io" ];
  };

  # ══ Virtualisation tools (were in packages.nix) ═════════════════════════════

  environment.systemPackages = with pkgs; [
    distrobox	# Distro Virtualization
    distroshelf	# GUI for distrobox
  ];

  programs.virt-manager.enable = true;
}
