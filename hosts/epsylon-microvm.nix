{ config, lib, pkgs, agenix, ... }:

{
  imports = [
    ../modules/common.nix
    ../modules/k3s-server.nix
    agenix.nixosModules.default
  ];

  networking.hostName = "epsylon";

  # microvm.nix uses eth0 for the first virtio-net interface
  networking.interfaces.eth0.useDHCP = false;
  networking.interfaces.eth0.ipv4.addresses = [
    {
      address = "192.168.0.106";
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
        id = "tap-epsylon";
        mac = "02:00:00:00:00:01";
      }
    ];

    # 50 GiB root — etcd data lives here
    volumes = [
      {
        image = "epsylon-root.img";
        mountPoint = "/";
        size = 51200;
      }
    ];
  };

  system.stateVersion = "24.11";
}
