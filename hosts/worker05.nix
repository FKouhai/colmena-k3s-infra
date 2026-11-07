{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./worker05-hardware-configuration.nix
    ../modules/common.nix
    ../modules/hardware-arm.nix
    ../modules/k3s-server.nix
  ];

  networking.hostName = "worker05";
  networking.interfaces.end0.useDHCP = false;
  networking.interfaces.end0.ipv4.addresses = [
    {
      address = "192.168.0.101";
      prefixLength = 24;
    }
  ];

  # Sole surviving server: module defaults are the shape we want
  # (clusterInit is a no-op on already-initialized etcd, no join address).

  system.stateVersion = "24.11";
}
