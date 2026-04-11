{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Ensure the k3s config drop-in directory exists for agenix to write into
  systemd.tmpfiles.rules = [
    "d /etc/rancher/k3s/config.yaml.d 0700 root root -"
  ];

  # Garage S3 credentials as a k3s config drop-in (contains access+secret key)
  age.secrets.k3s-s3-creds = {
    file = ../secrets/k3s-s3-creds.yaml.age;
    path = "/etc/rancher/k3s/config.yaml.d/s3-creds.yaml";
    owner = "root";
    mode = "0400";
  };

  services.k3s = {
    package = pkgs.k3s;
    enable = true;
    role = "server";
    token = "REDACTED";
    clusterInit = true;
    extraFlags = [
      "--flannel-backend=none"
      "--disable=traefik"
      "--disable=servicelb"
      "--disable-kube-proxy"
      "--disable-network-policy"
      "--write-kubeconfig-mode=644"
      # etcd snapshots → Garage S3 on unraid (192.168.0.33)
      "--etcd-s3"
      "--etcd-s3-endpoint=192.168.0.33:9000"
      "--etcd-s3-bucket=etcd-snapshots"
      "--etcd-s3-bucket-lookup-type=path"
      "--etcd-s3-region=garage"
      "--etcd-s3-insecure"
      "--etcd-s3-retention=2"
      "--etcd-snapshot-schedule-cron=0 */12 * * *"
      "--etcd-snapshot-retention=2"
    ];
  };

  environment.systemPackages = with pkgs; [
    kubernetes-helm
    cilium-cli
  ];
}
