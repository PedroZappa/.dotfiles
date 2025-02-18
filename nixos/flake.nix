#
#  flake.nix *
#   ├─ ./linux
#   │   └─ default.nix
#   ├─ ./darwin :TODO
#   │   └─ default.nix
#   └─ ./nix
#       └─ default.nix
#

# Use Flake on fresh install
/* Setup SSH key on Github */
# sudo su
# nix-env -iA nixos.git
# git clone git@github.com:PedroZappa/.dotfiles.git
# nixos-install --flake ".dotfiles/nixos#<host>"
# reboot
/* Log back in */
# sudo rm -fr /etc/nixos/configuration.nix
/* Create symlinks */

{
  description = "Zedro's NixOS/Home-Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable"; # Unstable Nix Packages
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05"; # Unstable Nix Packages
    nixos-hardware.url = "github:nixos/nixos-hardware/master"; # Hardware Specific Configurations

    home-manager = {
      url = "github:nix-community/home-manager?ref=release-24.11";
      inputs.nixpkgs.follows = "nixpkgs"; # Use nixpkgs
    };

    # Stable User Environment Manager
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

  };

  outputs = inputs @ { self, nixpkgs, nixpkgs-stable, nixos-hardware, home-manager, home-manager-stable, ... }: 
    let
      # Variables Used In Flake
      vars = {
        system = "x86_64-linux";
        user = "zedro";
        home = "/home/${vars.user}";
        location = "$HOME/.dotfiles/nixos";
        terminal = "ghostty";
        editor = "nvim";
      };
    in {
      # System Wide Config
      nixosConfigurations = {
        import = ./hosts {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs nixpkgs-stable nixos-hardware home-manager vars;
        };
      };
      # darwinConfigurations = (
      #   import ./darwin {
      #     inherit (nixpkgs) lib;
      #     inherit inputs nixpkgs nixpkgs-stable home-manager darwin vars;
      #   }
      # );
      # homeConfigurations = (
      #   import ./nix {
      #     inherit (nixpkgs) lib;
      #     inherit inputs nixpkgs nixpkgs-stable home-manager nixgl vars;
      #   }
      # );
    };
}
