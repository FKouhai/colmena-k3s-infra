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

  networking.networkmanager.enable = true;
  networking.defaultGateway = "192.168.0.1";
  networking.nameservers = [ "192.168.0.2" ];
  networking.enableIPv6 = false;

  services.xserver.enable = false;
  services.printing.enable = false;

  users.users.nixos = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBKu3fE8NcO2Gq0YHmxbVq8EDurGixJbv81KA+InsFKCJ6WczozZUWue202/Ri2DZNXFp1gx2aX8mhjbdmK7jvKM= franky@frarch"
    ];
    extraGroups = [ "wheel" ];
  };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    vim
    curl
    git
    python3
    wget
    nfs-utils
  ];

  services.openssh = {
    enable = true;
    settings = {
      AllowUsers = [ "nixos" ];
      PermitRootLogin = "no";
    };
  };

  boot.initrd = {
    supportedFilesystems = [ "nfs" ];
    kernelModules = [ "nfs" ];
  };

  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernelParams = [
    "cgroup_enable=cpuset"
    "cgroup_memory=1"
    "cgroup_enable=memory"
    "ip_tables"
    "iptable_nat"
    "iptable_mangle"
    "iptable_raw"
    "iptable_filter"
    "xt_socket"
  ];

  networking.firewall = {
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
}
