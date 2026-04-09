{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.k3s = {
    package = pkgs.k3s;
    enable = true;
    role = "server";
    token = "REDACTED";
    clusterInit = true;
    extraFlags = toString [
      "--flannel-backend=none --disable traefik --disable kube-proxy --disable-network-policy --write-kubeconfig-mode=644"
    ];
  };

  environment.systemPackages = with pkgs; [
    kubernetes-helm
  ];
}
