#
#  These are the different profiles that can be used when building NixOS.
#
#  flake.nix
#   └─ ./hosts
#       ├─ default.nix *
#       ├─ configuration.nix
#       └─ ./<host>.nix
#           └─ default.nix
#

{ lib, vars, inputs, nixpkgs, nixpkgs-stable, home-manager, ... }:

let
  system = "x86_64-linux";
  # system = vars.system;

  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  stable = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };

  lib = nixpkgs.lib;
in
{
  z = lib.nixosSystem { # Desktop Profile
    inherit system;
    specialArgs = { 
      inherit inputs vars stable system; 
      host = {
        hostname = "znix-desk";
        mainMonitor = "HDMI-A-2";
        secondMonitor = "HDMI-A-1";
      };
    };
    modules = [
      ./desktop
      ./configuration.nix

      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ];
  };
}
