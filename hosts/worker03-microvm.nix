{ config, lib, pkgs, agenix, ... }:

{
  imports = [
    ../modules/common.nix
    ../modules/k3s-agent.nix
    agenix.nixosModules.default
  ];

  networking.hostName = "worker03";

  networking.interfaces.eth0.useDHCP = false;
  networking.interfaces.eth0.ipv4.addresses = [
    {
      address = "192.168.0.104";
      prefixLength = 24;
    }
  ];

  microvm = {
    hypervisor = "qemu";

    interfaces = [
      {
        type = "tap";
        id = "tap-worker03";
        mac = "02:00:00:00:00:02";
      }
    ];

    volumes = [
      {
        image = "worker03-root.img";
        mountPoint = "/";
        size = 51200;
      }
    ];
  };

  system.stateVersion = "24.11";
}
