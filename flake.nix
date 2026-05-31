{
  description = "NixOS cluster deployment via Colmena";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    aphelion.url = "github:FKouhai/aphelion";
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
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";
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
            system = "x86_64-linux";
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
          ];
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
          ];
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
          ];
          deployment = {
            targetHost = "192.168.0.105";
            targetUser = "nixos";
            tags = [ "workers" ];
            buildOnTarget = true;
          };
        };
      };

      nixosConfigurations.copernico = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit agenix; };
        modules = [
          { nixpkgs.overlays = [ nix-cachyos-kernel.overlays.default ]; }
          aphelion.nixosModules.default
          microvm.nixosModules.host
          disko.nixosModules.disko
          ./hosts/copernico.nix
          ./hosts/copernico-disk.nix
        ];
      };

      devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
        packages = with nixpkgs.legacyPackages.x86_64-linux; [
          colmena
        ];
      };
    };
}
