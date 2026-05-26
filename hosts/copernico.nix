{ config, lib, pkgs, agenix, ... }:

{
  imports = [
    ../modules/common.nix
  ];

  networking.hostName = "copernico";

  # common.nix enables NetworkManager, but a hypervisor host is better served
  # by systemd-networkd for reliable bridge + tap interface management.
  networking.networkmanager.enable = lib.mkForce false;
  systemd.network.enable = true;

  systemd.network = {
    netdevs."10-br0".netdevConfig = {
      Kind = "bridge";
      Name = "br0";
    };

    networks = {
      "10-uplink" = {
        matchConfig.Name = "enp37s0";
        networkConfig.Bridge = "br0";
      };

      "10-br0" = {
        matchConfig.Name = "br0";
        networkConfig = {
          IPv4Forwarding = true;
          Address = "192.168.0.19/24";
          Gateway = "192.168.0.1";
          DNS = "192.168.0.2";
        };
      };

      # All tap-* interfaces (one per microvm) are automatically bridged
      "20-tap" = {
        matchConfig.Name = "tap-*";
        networkConfig.Bridge = "br0";
      };
    };
  };

  services.openssh.settings.PermitRootLogin = lib.mkForce "no";

  # common.nix already adds the ECDSA key; add the ed25519 key too so
  # either key works on this headless host.
  users.users.nixos.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFyWsnvAIM23SRQCW4AIPKeNhVeCWtez/CV1hDegCunC"
  ];

  microvm.host.enable = true;

  microvm.vms = {
    epsylon = {
      specialArgs = { inherit agenix; };
      config = {
        imports = [ ./epsylon-microvm.nix ];
      };
    };

    worker03 = {
      specialArgs = { inherit agenix; };
      config = {
        imports = [ ./worker03-microvm.nix ];
      };
    };

    worker04 = {
      specialArgs = { inherit agenix; };
      config = {
        imports = [ ./worker04-microvm.nix ];
      };
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.cachyosKernels."linuxPackages-cachyos-latest-x86_64-v3";
  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "usb_storage" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-amd" ];

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;

  services.tailscale.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  nix.settings = {
    auto-optimise-store = true;
    substituters = [ "https://attic.xuyh0120.win/lantian" ];
    trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  system.stateVersion = "24.11";
}
