{ config, lib, pkgs, ... }:

{
  services.openssh.hostKeys = [
    { path = "/var/lib/ssh/ssh_host_ed25519_key"; type = "ed25519"; }
    { path = "/var/lib/ssh/ssh_host_rsa_key"; type = "rsa"; bits = 4096; }
  ];

  systemd.tmpfiles.rules = [
    "d /var/lib/ssh 0700 root root -"
  ];

  # Bind-mount a persistent directory over /etc/rancher/node so the k3s node
  # password survives reboots. /etc is ephemeral in microvms; without this the
  # password is regenerated each boot and the server rejects the node.
  systemd.services.k3s-node-passwd-mount = {
    description = "Mount persistent k3s node password directory";
    before = [ "k3s.service" ];
    wantedBy = [ "k3s.service" ];
    after = [ "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart =
        let
          script = pkgs.writeShellScript "k3s-mount-node-passwd" ''
            mkdir -p /var/lib/rancher-node /etc/rancher/node
            chmod 700 /var/lib/rancher-node
            if ! ${pkgs.util-linux}/bin/mountpoint -q /etc/rancher/node; then
              ${pkgs.util-linux}/bin/mount --bind /var/lib/rancher-node /etc/rancher/node
            fi
          '';
        in
        "+${script}";
      ExecStop = "+${pkgs.util-linux}/bin/umount /etc/rancher/node";
    };
  };

  systemd.services.sshd = {
    after = [ "var.mount" ];
    wants = [ "var.mount" ];
  };

  systemd.services.k3s = {
    after = [ "network-online.target" "var.mount" ];
    wants = [ "network-online.target" ];
    requires = [ "var.mount" ];
  };
}
