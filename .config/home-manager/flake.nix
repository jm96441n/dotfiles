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
    aoe = {
      url = "github:njbrake/agent-of-empires";
    };
    hunk = {
      url = "github:modem-dev/hunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      nixpkgs,
      home-manager,
      ghostty,
      nixgl,
      aoe,
      hunk,
      ...
    }:
    let
      system = "x86_64-linux";
    in
    {
      homeConfigurations."johnmaguire" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        extraSpecialArgs = { inherit aoe hunk system; };

        modules = [
          {
            nixpkgs.overlays = [
              ghostty.overlays.default
              nixgl.overlays.default
            ];
          }
          ./home.nix
        ];
      };
    };
}
