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

  boot.kernelPackages = pkgs."linuxPackages-cachyos-latest-x86_64-v3";

  microvm = {
    hypervisor = "qemu";
    mem = 6144;  # 6 GiB — matches previous Harvester allocation
    vcpu = 4;

    interfaces = [
      {
        type = "tap";
        id = "tap-epsylon";
        mac = "02:00:00:00:00:01";
      }
    ];

    # Share the host nix store read-only; microvm.nix overlays a writable
    # tmpfs layer so the VM sees a normal /nix/store.
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
        image = "epsylon-var.img";
        mountPoint = "/var";
        size = 122880; # 120 GiB — etcd, k3s state, containerd cache, nix overlay
      }
    ];
  };

  system.stateVersion = "24.11";
}
