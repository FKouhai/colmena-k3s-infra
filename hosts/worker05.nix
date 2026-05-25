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

  # Join the existing cluster rather than bootstrapping a new one
  services.k3s.clusterInit = lib.mkForce false;
  services.k3s.serverAddr = "https://192.168.0.106:6443";

  system.stateVersion = "24.11";
}
