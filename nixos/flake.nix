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
        modules = [./configuration.nix];
      };
      specialArgs = {inherit zap-zsh;};
    };
    # Home Manager cxonfig
    homeConfig = {
      ${vars.user} = home-manager.lib.homeManagerConfiguration {
        # inherit system pkgs;
        pkgs = nixpkgs.legacyPackages.${vars.system};
        modules = [
          ../home-manager/home.nix
        ];
      };
    };
  };
}
