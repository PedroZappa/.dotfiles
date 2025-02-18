{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;  
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        znix = lib.nixosSystem {
          inherit system;
          modules = [ ./configuration.nix ];
        };
      };
    };
}
