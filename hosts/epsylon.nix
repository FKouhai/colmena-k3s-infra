{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./epsylon-hardware-configuration.nix
    ../modules/common.nix
    ../modules/hardware-x86.nix
    ../modules/k3s-server.nix
  ];

  networking.hostName = "epsylon";
  networking.interfaces.enp1s0.useDHCP = false;
  networking.interfaces.enp1s0.ipv4.addresses = [
    {
      address = "192.168.0.106";
      prefixLength = 24;
    }
  ];

  fileSystems."/mnt/NAS" = {
    device = "192.168.0.33:/mnt/user/Babylon";
    fsType = "nfs";
  };

  system.stateVersion = "24.11";
}
