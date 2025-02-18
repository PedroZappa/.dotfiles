{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Use nixpkgs
    };
  };

  outputs = { self, nixpkgs, home-manager }: 
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;  
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
      user = "zedro";
    in {
      # System Wide Config
      nixosConfigurations = {
        znix = lib.nixosSystem {
          inherit system;
          modules = [ ./configuration.nix ];
        };
      };
      # Home Manager cxonfig
      hmConfig = {
        znix = home-manager.lib.homeManagerConfiguration {
          inherit system pkgs;
          username = user;
          homeDirectory = "/home/zedro/";
          configuration = {
            imports = [
              /home/zedro/.dotfiles/home-manager/home.nix
            ];
          };
        };
      };
    };
}
