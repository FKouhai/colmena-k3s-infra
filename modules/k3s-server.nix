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

  # K3S token used for nodes to join the cluster
  age.secrets.cluster-token = {
    file = ../secrets/cluster-token.age;
    path = "/etc/rancher/k3s/token";
    owner = "root";
    mode = "0400";
  };

  # S3 snapshot settings as a config drop-in so both k3s server and
  # k3s etcd-snapshot subcommand can read them (credentials come from s3-creds.yaml via agenix)
  environment.etc."rancher/k3s/config.yaml.d/etcd-s3.yaml" = {
    text = ''
      etcd-s3: true
      etcd-s3-endpoint: "192.168.0.33:9000"
      etcd-s3-bucket: "etcd-snapshots"
      etcd-s3-bucket-lookup-type: "path"
      etcd-s3-region: "auto"
      etcd-s3-insecure: true
      etcd-s3-retention: 5
      etcd-snapshot-retention: 5
      etcd-snapshot-schedule-cron: "0 */12 * * *"
    '';
    mode = "0400";
  };

  services.k3s = {
    package = pkgs.k3s;
    enable = true;
    role = "server";
    tokenFile = config.age.secrets.cluster-token.path;
    clusterInit = true;
    extraFlags = [
      "--flannel-backend=none"
      "--disable=traefik"
      "--disable=servicelb"
      "--disable-kube-proxy"
      "--disable-network-policy"
      "--write-kubeconfig-mode=644"
    ];
  };

  environment.systemPackages = with pkgs; [
    kubernetes-helm
    cilium-cli
  ];
}
