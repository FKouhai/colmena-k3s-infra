{
  config,
  lib,
  pkgs,
  ...
}:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  networking = {
    networkmanager = {
      enable = true;
      unmanaged = [
        "interface-name:cilium*"
        "interface-name:lxc*"
      ];
    };

    dhcpcd.denyInterfaces = [
      "lxc*"
      "cilium*"
    ];

    defaultGateway = "192.168.0.1";
    nameservers = [ "192.168.0.2" ];
    enableIPv6 = false;
    wireguard.enable = true;

    firewall = {
      trustedInterfaces = [
        "cilium_host"
        "cilium_net"
        "lxc+"
      ];
      allowedTCPPorts = [
        80 # HTTP ingress
        443 # HTTPS ingress
        4240 # Cilium health checks
        4244 # Hubble
        5001 # k3s' embedded Spegel
        6443 # k3s supervisor; k8s API
        7946 # MetalLB
        9100 # Prometheus Node Exporter
        9962 # cilium-agent metrics
        9963 # cilium-operator metrics
        10250 # kubelet metrics
        2379
        2380

      ];
      allowedUDPPorts = [
        8472 # Cilium VXLAN
        51871 # Cilium WireGuard
      ];

      # Reverse-path filtering is discouraged by Cilium.
      # cilium-1.15.2/pkg/datapath/loader/base.go:365
      checkReversePath = false;
    };
  };

  services = {
    xserver.enable = false;
    printing.enable = false;

    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        AllowUsers = [ "nixos" ];
        PermitRootLogin = "no";
      };
    };
  };

  users.users.nixos = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBKu3fE8NcO2Gq0YHmxbVq8EDurGixJbv81KA+InsFKCJ6WczozZUWue202/Ri2DZNXFp1gx2aX8mhjbdmK7jvKM= franky@frarch"
    ];
    extraGroups = [ "wheel" ];
  };
  # https://docs.cilium.io/en/stable/security/network/encryption-wireguard/

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    vim
    curl
    git
    python3
    wget
    nfs-utils
  ];

  boot = {
    initrd = {
      supportedFilesystems = [ "nfs" ];
      kernelModules = [ "nfs" ];
    };
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv4.conf.all.rp_filter" = 0;
      "net.ipv4.conf.default.rp_filter" = 0;
      "net.bridge.bridge-nf-call-iptables" = 1;
      "net.bridge.bridge-nf-call-ip6tables" = 1;
      "kernel.panic" = 10; # auto-reboot on kernel panic
      "kernel.panic_on_oops" = 1; # important for RPis especially
    };
    kernelParams = [
      "cgroup_enable=cpuset"
      "cgroup_memory=1"
      "cgroup_enable=memory"
      "systemd.unified_cgroup_hierarchy=1"

    ];
    kernelModules = [
      "ip_tables"
      "iptable_nat"
      "iptable_mangle"
      "iptable_raw"
      "iptable_filter"
      "xt_socket"
      "br_netfilter"
      "overlay"
    ];
  };

}
