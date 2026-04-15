# colmena

NixOS + [Colmena](https://github.com/zhaofengli/colmena) configuration for a mixed-architecture k3s cluster on a home network.

## Cluster overview

| Node | IP | Arch | Role |
|------|-----|------|------|
| epsylon | 192.168.0.106 | x86_64 | k3s server (control plane) |
| master | 192.168.0.101 | aarch64 | k3s agent |
| worker01 | 192.168.0.102 | aarch64 | k3s agent |
| worker02 | 192.168.0.103 | aarch64 | k3s agent |
| worker03 | 192.168.0.104 | x86_64 | k3s agent |
| worker04 | 192.168.0.105 | x86_64 | k3s agent |

x86_64 nodes run as QEMU VMs; aarch64 nodes are ARM single-board computers.

## Stack

- **NixOS** (nixos-unstable) — declarative OS configuration
- **Colmena** — multi-host NixOS deployment tool
- **k3s** — lightweight Kubernetes
- **Cilium** — CNI (no kube-proxy, no Flannel)
- **MetalLB** — bare-metal load balancer
- **agenix** — age-encrypted secrets management
- **Garage** — S3-compatible object storage for etcd snapshots (192.168.0.33)
- **NFS** — persistent storage from NAS (192.168.0.33) on epsylon and worker04

## Repository structure

```
.
├── flake.nix                  # Cluster definition and node declarations
├── hosts/                     # Per-node NixOS configurations
│   ├── epsylon.nix
│   ├── master.nix
│   ├── worker{01..04}.nix
│   └── *-hardware-configuration.nix
├── modules/
│   ├── common.nix             # Shared config (networking, SSH, firewall, users)
│   ├── k3s-server.nix         # Control plane config + etcd S3 snapshots
│   ├── k3s-agent.nix          # Worker node config
│   ├── hardware-x86.nix       # GRUB + QEMU guest tools
│   └── hardware-arm.nix       # extlinux bootloader for ARM
└── secrets/
    ├── secrets.nix            # Age public key declarations
    ├── cluster-token.age      # k3s cluster join token
    └── k3s-s3-creds.yaml.age  # Garage S3 credentials for etcd snapshots
```

## Usage

Enter the dev shell (provides `colmena`):

```bash
nix develop
# or with direnv: direnv allow
```

Deploy to all nodes:

```bash
colmena apply
```

Deploy to a specific tag:

```bash
colmena apply --on @masters
colmena apply --on @workers
```

Deploy to a specific node:

```bash
colmena apply --on epsylon
```

## Secrets

Secrets are managed with [agenix](https://github.com/ryantm/agenix). Each `.age` file is encrypted to the host SSH keys of the nodes that need it, plus the `franky` personal key.

To re-key after adding a new node, update `secrets/secrets.nix` with the node's host public key, then:

```bash
agenix -r
```

## Networking

All nodes are on `192.168.0.0/24`. The firewall is pre-opened for:

- **6443** — k3s API server
- **2379–2380** — etcd
- **10250** — kubelet
- **4240, 4244, 9962–9963** — Cilium health/Hubble/metrics
- **8472 UDP** — VXLAN
- **51871 UDP** — WireGuard
- **7946** — MetalLB
- **5001** — Spegel (image distribution)
