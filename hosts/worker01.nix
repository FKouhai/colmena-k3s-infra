{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../modules/common.nix
    ../modules/hardware-arm.nix
    ../modules/k3s-agent.nix
  ];

  networking.hostName = "worker01";
  networking.interfaces.end0.useDHCP = false;
  networking.interfaces.end0.ipv4.addresses = [
    {
      address = "192.168.0.102";
      prefixLength = 24;
    }
  ];

  system.stateVersion = "24.11";
}
