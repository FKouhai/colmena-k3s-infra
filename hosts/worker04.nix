{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./worker04-hardware-configuration.nix
    ../modules/common.nix
    ../modules/hardware-x86.nix
    ../modules/k3s-agent.nix
  ];

  networking.hostName = "worker04";
  networking.interfaces.enp1s0.useDHCP = false;
  networking.interfaces.enp1s0.ipv4.addresses = [
    {
      address = "192.168.0.105";
      prefixLength = 24;
    }
  ];

  fileSystems."/mnt/NAS" = {
    device = "192.168.0.33:/mnt/user/Babylon";
    fsType = "nfs";
  };

  system.stateVersion = "24.11";
}
