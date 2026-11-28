{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hunk = {
      url = "github:modem-dev/hunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rex = {
      url = "https://pkgs.superlogical.com/rex/nix/snapshot.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      nixpkgs,
      home-manager,
      ghostty,
      nixgl,
      hunk,
      nixos-hardware,
      sops-nix,
      zen-browser,
      rex,
      nix-darwin,
      ...
    }:
    let
      system = "x86_64-linux";
      overlays = [
        ghostty.overlays.default
        nixgl.overlays.default
      ];

      mkNixos =
        system: machine:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            { nixpkgs.overlays = overlays; }
            ./machines/shared.nix
            rex.nixosModules.default
            machine
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit hunk; };
              home-manager.users.johnmaguire = {
                imports = [ ./home ];
                targets.genericLinux.enable = nixpkgs.lib.mkForce false;
              };
            }
          ];
        };
    in
    {
      # Non-NixOS Linux (current laptop)
      homeConfigurations."johnmaguire" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        extraSpecialArgs = { inherit hunk; };

        modules = [
          { nixpkgs.overlays = overlays; }
          ./home
          rex.homeManagerModules.default
          {
            programs.rex.enable = true;
            services.rex.enable = true;
          }
        ];
      };

      # VMware Fusion VM on Apple Silicon Macs
      nixosConfigurations.dev-vm = mkNixos "aarch64-linux" {
        imports = [ ./machines/dev-vm.nix ];
      };

      # ThinkPad P1 Gen 3
      nixosConfigurations.home-laptop = mkNixos "x86_64-linux" {
        imports = [
          nixos-hardware.nixosModules.lenovo-thinkpad-p1-gen3
          ./machines/home-laptop.nix
          ./machines/desktop-apps.nix
          { environment.systemPackages = [ zen-browser.packages.x86_64-linux.default ]; }
        ];
      };

      # ThinkStation P520 home server (ZFS media pool, docker compose)
      nixosConfigurations.homelab = mkNixos "x86_64-linux" {
        imports = [
          sops-nix.nixosModules.sops
          ./machines/homelab.nix
        ];
      };

      # Work MacBook: GUI apps only, dev work happens in dev-vm via Rex
      darwinConfigurations.work-mac = nix-darwin.lib.darwinSystem {
        modules = [
          ./machines/work-mac.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.johnmaguire = ./home/darwin.nix;
          }
        ];
      };
    };
}
