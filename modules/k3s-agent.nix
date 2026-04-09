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
    role = "agent";
    token = "REDACTED";
    serverAddr = "https://192.168.0.101:6443";
  };
}
