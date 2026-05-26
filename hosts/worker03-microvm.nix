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

  boot.kernelPackages = pkgs."linuxPackages-cachyos-latest-x86_64-v3";

  microvm = {
    hypervisor = "qemu";
    mem = 8192;  # 8 GiB — matches previous Harvester allocation
    vcpu = 4;

    interfaces = [
      {
        type = "tap";
        id = "tap-worker03";
        mac = "02:00:00:00:00:02";
      }
    ];

    shares = [
      {
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }
    ];
    writableStoreOverlay = "/var/nix-rw-store";

    volumes = [
      {
        image = "worker03-var.img";
        mountPoint = "/var";
        size = 122880; # 120 GiB — containerd cache, k3s agent state, nix overlay
      }
    ];
  };

  system.stateVersion = "24.11";
}
