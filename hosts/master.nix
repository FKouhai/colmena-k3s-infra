{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./master-hardware-configuration.nix
    ../modules/common.nix
    ../modules/hardware-arm.nix
    ../modules/k3s-server.nix
  ];

  networking.hostName = "master";
  networking.interfaces.end0.useDHCP = false;
  networking.interfaces.end0.ipv4.addresses = [
    {
      address = "192.168.0.101";
      prefixLength = 24;
    }
  ];

  system.stateVersion = "24.11";
}
