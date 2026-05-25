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

  # Allow SSH from the nixos user (common.nix configures the key)
  services.openssh.settings.PermitRootLogin = lib.mkForce "no";

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

  # Enable KVM for hardware-accelerated virtualisation
  boot.kernelModules = [ "kvm-amd" ];

  system.stateVersion = "24.11";
}
