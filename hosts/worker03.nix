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
    ../modules/hardware-x86.nix
    ../modules/k3s-agent.nix
  ];

  networking.hostName = "worker03";
  networking.interfaces.enp1s0.useDHCP = false;
  networking.interfaces.enp1s0.ipv4.addresses = [
    {
      address = "192.168.0.104";
      prefixLength = 24;
    }
  ];

  system.stateVersion = "24.11";
}
