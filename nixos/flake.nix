{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-24.11";
      inputs.nixpkgs.follows = "nixpkgs"; # Use nixpkgs
    };
  };

  outputs = { self, nixpkgs, home-manager }: 
    let
      # Variables Used In Flake
      vars = {
        system = "x86_64-linux";
        user = "zedro";
        location = "$HOME/.dotfiles/nixos";
        terminal = "ghostty";
        editor = "nvim";
      };
      system = vars.system;
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
      homeConfig = {
        ${user} = home-manager.lib.homeManagerConfiguration {
          # inherit system pkgs;
          pkgs = nixpkgs.legacyPackages.${vars.system};
          modules = [
            ../home-manager/home.nix
          ];
        };
      };
    };
}
