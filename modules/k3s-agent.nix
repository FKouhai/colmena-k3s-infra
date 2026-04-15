{
  config,
  lib,
  pkgs,
  ...
}:

{
  age.secrets.cluster-token = {
    file = ../secrets/cluster-token.age;
    path = "/etc/rancher/k3s/token";
    owner = "root";
    mode = "0400";
  };

  services.k3s = {
    package = pkgs.k3s;
    enable = true;
    role = "agent";
    tokenFile = config.age.secrets.cluster-token.path;
    serverAddr = "https://192.168.0.106:6443";
  };
}
