{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-24.11";
      inputs.nixpkgs.follows = "nixpkgs"; # Use nixpkgs
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
  }: let
    # Variables Used In Flake
    vars = {
      system = "x86_64-linux";
      hostname = "znix";
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
    zap-zsh = import ./zap-zsh.nix {inherit (pkgs) lib stdenv fetchFromGitHub;};
  in {
    # System Wide Config
    nixosConfigurations = {
      ${vars.hostname} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [ 
          ./configuration.nix 
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${vars.user} = import ./home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
      };
      specialArgs = {inherit zap-zsh;};
    };
  };
}
