{
  description = "NixOS cluster deployment via Colmena";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    aphelion.url = "path:/home/franky/sw/go/aphelion";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/2e3d6f313f83b7eacd94467c0f693c87774872a5"; # pin to 7.1.8 for cilium #48016 — 7.2 breaks FnSetRetval probe (fixed in cilium 67c619c not yet in 1.20.1)
  };

  outputs =
    {
      self,
      aphelion,
      nixpkgs,
      agenix,
      disko,
      microvm,
      nix-cachyos-kernel,
    }:
    let
      lib = nixpkgs.lib;

      # Imported into every microvm NixOS config — both via colmena direct
      # deploy and via copernico's microvm.vms definitions.
      microvmLogd = [
        aphelion.nixosModules.aphelion-logd
        {
          services.aphelion-logd = {
            enable = true;
            openFirewall = true;
          };
        }
      ];

      mkNode =
        {
          hostname,
          ip,
          hostConfig,
          hardwareConfig,
          tags ? [ ],
          buildOnTarget ? false,
        }:
        {
          imports = [
            hostConfig
            hardwareConfig
            agenix.nixosModules.default
          ];

          deployment = {
            targetHost = ip;
            targetUser = "nixos";
            inherit tags buildOnTarget;
          };
        };

    in
    {
      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            localSystem = "x86_64-linux";
            overlays = [
              aphelion.overlays.default
              nix-cachyos-kernel.overlays.default
            ];
          };
          specialArgs = { inherit lib agenix; };
        };

        epsylon = {
          imports = [
            microvm.nixosModules.microvm
            ./hosts/epsylon-microvm.nix
            agenix.nixosModules.default
          ]
          ++ microvmLogd;
          deployment = {
            targetHost = "192.168.0.106";
            targetUser = "nixos";
            tags = [ "masters" ];
            buildOnTarget = true;
          };
        };

        worker05 = mkNode {
          hostname = "worker05";
          ip = "192.168.0.101";
          hostConfig = ./hosts/worker05.nix;
          hardwareConfig = ./hosts/worker05-hardware-configuration.nix;
          tags = [ "workers" ];
          buildOnTarget = true;
        };

        worker01 = {
          imports = [
            ./hosts/worker01.nix
            ./hosts/worker01-hardware-configuration.nix
            agenix.nixosModules.default
          ];
          deployment = {
            targetHost = "192.168.0.102";
            targetUser = "nixos";
            tags = [ "workers" ];
            buildOnTarget = true;
          };
        };

        worker02 = {
          imports = [
            ./hosts/worker02.nix
            ./hosts/worker02-hardware-configuration.nix
            agenix.nixosModules.default
          ];
          deployment = {
            targetHost = "192.168.0.103";
            targetUser = "nixos";
            tags = [ "workers" ];
            buildOnTarget = true;
          };
        };

        worker03 = {
          imports = [
            microvm.nixosModules.microvm
            ./hosts/worker03-microvm.nix
            agenix.nixosModules.default
          ]
          ++ microvmLogd;
          deployment = {
            targetHost = "192.168.0.104";
            targetUser = "nixos";
            tags = [ "workers" ];
            buildOnTarget = true;
          };
        };

        worker04 = {
          imports = [
            microvm.nixosModules.microvm
            ./hosts/worker04-microvm.nix
            agenix.nixosModules.default
          ]
          ++ microvmLogd;
          deployment = {
            targetHost = "192.168.0.105";
            targetUser = "nixos";
            tags = [ "workers" ];
            buildOnTarget = true;
          };
        };
      };

      nixosConfigurations.copernico = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit agenix; };
        modules = [
          { nixpkgs.hostPlatform = "x86_64-linux"; }
          { nixpkgs.overlays = [ nix-cachyos-kernel.overlays.default ]; }
          aphelion.nixosModules.aphelion-agent
          microvm.nixosModules.host
          disko.nixosModules.disko
          ./hosts/copernico.nix
          ./hosts/copernico-disk.nix
          # Inject aphelion-logd into each VM definition so the image built
          # by copernico also carries the daemon.
          {
            microvm.vms.epsylon.config.imports = microvmLogd;
            microvm.vms.worker03.config.imports = microvmLogd;
            microvm.vms.worker04.config.imports = microvmLogd;
          }
        ];
      };

      devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
        packages = with nixpkgs.legacyPackages.x86_64-linux; [
          colmena
        ];
      };
    };
}
