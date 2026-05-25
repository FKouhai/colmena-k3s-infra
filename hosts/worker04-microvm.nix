{ config, lib, pkgs, agenix, ... }:

{
  imports = [
    ../modules/common.nix
    ../modules/k3s-agent.nix
    agenix.nixosModules.default
  ];

  networking.hostName = "worker04";

  networking.interfaces.eth0.useDHCP = false;
  networking.interfaces.eth0.ipv4.addresses = [
    {
      address = "192.168.0.105";
      prefixLength = 24;
    }
  ];

  fileSystems."/mnt/NAS" = {
    device = "192.168.0.33:/mnt/user/Babylon";
    fsType = "nfs";
  };

  microvm = {
    hypervisor = "qemu";

    interfaces = [
      {
        type = "tap";
        id = "tap-worker04";
        mac = "02:00:00:00:00:03";
      }
    ];

    volumes = [
      {
        image = "worker04-root.img";
        mountPoint = "/";
        size = 51200;
      }
    ];
  };

  system.stateVersion = "24.11";
}
