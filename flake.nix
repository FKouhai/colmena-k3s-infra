{
  description = "NixOS cluster deployment via Colmena";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, agenix }:
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
          };
          specialArgs = { inherit lib; };
        };

        epsylon = {
          imports = [
            ./hosts/epsylon.nix
            ./hosts/epsylon-hardware-configuration.nix
            agenix.nixosModules.default
          ];
          deployment = {
            targetHost = "192.168.0.106";
            targetUser = "nixos";
            tags = [ "masters" ];
            buildOnTarget = true;
          };
        };

        master = mkNode {
          hostname = "master";
          ip = "192.168.0.101";
          hostConfig = ./hosts/master.nix;
          hardwareConfig = ./hosts/master-hardware-configuration.nix;
          tags = [ "workers" ];
          buildOnTarget = true;
        };

        worker01 = mkNode {
          hostname = "worker01";
          ip = "192.168.0.102";
          hostConfig = ./hosts/worker01.nix;
          hardwareConfig = ./hosts/worker01-hardware-configuration.nix;
          tags = [ "workers" ];
          buildOnTarget = true;
        };

        worker02 = mkNode {
          hostname = "worker02";
          ip = "192.168.0.103";
          hostConfig = ./hosts/worker02.nix;
          hardwareConfig = ./hosts/worker02-hardware-configuration.nix;
          tags = [ "workers" ];
          buildOnTarget = true;
        };

        worker03 = mkNode {
          hostname = "worker03";
          ip = "192.168.0.104";
          hostConfig = ./hosts/worker03.nix;
          hardwareConfig = ./hosts/worker03-hardware-configuration.nix;
          tags = [ "workers" ];
        };

        worker04 = mkNode {
          hostname = "worker04";
          ip = "192.168.0.105";
          hostConfig = ./hosts/worker04.nix;
          hardwareConfig = ./hosts/worker04-hardware-configuration.nix;
          tags = [ "workers" ];
        };
      };

      devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
        packages = with nixpkgs.legacyPackages.x86_64-linux; [
          colmena
        ];
      };
    };
}
