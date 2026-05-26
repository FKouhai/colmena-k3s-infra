# colmena

NixOS + [Colmena](https://github.com/zhaofengli/colmena) configuration for a mixed-architecture k3s cluster on a home network.

## Cluster overview

| Node | IP | Arch | Role | Host |
|------|-----|------|------|------|
| worker05 | 192.168.0.101 | aarch64 | k3s server (control plane, etcd) | bare-metal |
| epsylon | 192.168.0.106 | x86_64 | k3s server (control plane, etcd) | microvm on copernico |
| worker01 | 192.168.0.102 | aarch64 | k3s agent | bare-metal |
| worker02 | 192.168.0.103 | aarch64 | k3s agent | bare-metal |
| worker03 | 192.168.0.104 | x86_64 | k3s agent | microvm on copernico |
| worker04 | 192.168.0.105 | x86_64 | k3s agent | microvm on copernico |
| copernico | 192.168.0.19 | x86_64 | microvm host | bare-metal |

aarch64 nodes are ARM single-board computers. x86_64 VMs (epsylon, worker03, worker04) run as QEMU microvms managed by [microvm.nix](https://github.com/astro/microvm.nix) on copernico.

## Stack

- **NixOS** (nixos-unstable) — declarative OS configuration
- **Colmena** — multi-host NixOS deployment tool
- **k3s** — lightweight Kubernetes (embedded etcd HA, two control planes)
- **Cilium** — CNI (no kube-proxy, no Flannel)
- **MetalLB** — bare-metal load balancer
- **agenix** — age-encrypted secrets management
- **microvm.nix** — NixOS-native QEMU microvm management
- **disko** — declarative disk partitioning (copernico)
- **Garage** — S3-compatible object storage for etcd snapshots (192.168.0.33)
- **NFS** — persistent storage from NAS (192.168.0.33)

## Repository structure

```
.
├── flake.nix                      # Cluster definition and node declarations
├── hosts/
│   ├── copernico.nix              # Bare-metal microvm host
│   ├── copernico-disk.nix         # disko disk layout for copernico
│   ├── epsylon-microvm.nix        # epsylon microvm guest config
│   ├── worker03-microvm.nix       # worker03 microvm guest config
│   ├── worker04-microvm.nix       # worker04 microvm guest config
│   ├── worker05.nix               # Primary control plane (aarch64)
│   ├── worker01.nix
│   ├── worker02.nix
│   └── *-hardware-configuration.nix
├── modules/
│   ├── common.nix                 # Shared config (networking, SSH, firewall, users)
│   ├── k3s-server.nix             # Control plane config + etcd S3 snapshots
│   ├── k3s-agent.nix              # Worker node config
│   ├── hardware-x86.nix           # GRUB + QEMU guest tools
│   └── hardware-arm.nix           # extlinux bootloader for ARM
└── secrets/
    ├── secrets.nix                # Age public key declarations
    ├── cluster-token.age          # k3s cluster join token
    └── k3s-s3-creds.yaml.age      # Garage S3 credentials for etcd snapshots
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
cd secrets && agenix --rekey
```

For fresh microvms, run `ssh-keyscan` after first boot to get the new host key before rekeying:

```bash
ssh-keyscan -t ed25519 <ip>
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
