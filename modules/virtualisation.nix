{ ... }:

{
  virtualisation.podman.enable = true;
  virtualisation.libvirtd.enable = true;

  virtualisation.containers.registries.settings = {
    unqualified-search-registries = [ "docker.io" ];
  };
}
