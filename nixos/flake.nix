{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
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
      home = "/home/${user}";
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
              "${home}".dotfiles/home-manager/home.nix
            ];
          };
        };
      };
    };
}
