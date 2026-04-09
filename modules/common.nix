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
  ];

  networking.firewall.enable = false;
}
