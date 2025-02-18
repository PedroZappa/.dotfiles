

{ config, pkgs, vars ...}:

{
  imports = 
    (import ./hardware-configuration.nix) ++
    (import ../../modules/hardware);

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # initrd.kernelModules = [ "nvidia" ];

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };
  };

  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
      ];
    };
    sane = { # For scanning with Xsane
      enable = true;
      extraBackends = [ pkgs.sane-airscan ];
    };
  };

  # hyprland.enable = true;

  environment = {
    systemPackages = with pkgs; [
      discord
      simple-scan
    ];
  };
  
  flatpak = {
    extraPackages = [
      "com.github.tchx84.Flatseal"
      "com.ultimaker.cura"
      "com.stremio.Stremio"
    ];
  };

  programs = {
  };

  # networking = {
  #   hostname =  "znix";
  #   #networkmanager.enable = true;
  #   interfaces = {
  #     enp3s0 = {
  #       # useDHCP = true;
  #       ipv4.address = [ {
  #         address = "192.168.0.50";
  #         prefixLength = 24;
  #       } ];
  #     };
  #     # wlp2s0.useDHCP = true;
  #   };
  #   defaultGateway = "192.168.0.1";
  #   nameservers = [ "1.1.1.1" ];
  # };

  # Overlays (Advanced Biz)
  nixpkgs.overlays = [
    (self: super: {
      discord = super.discord.overrideAttrs (
        _: { src = builtins.fetchTarball {
          url = "http://discord.com/api/download?platform=linux&format=tar.gz";
          sha256 = "1lfrnkq7qavlcbyjzn2m8kq39wn82z40dkpn6l5aijy12c775x7s";
        }; }
      );
    })
  ];

  # services = {
  #   blueman.enable = true;
  #   # printing = {
  #   #   enable = true;
  #   #   drivers = [ pkgs.cnijfilter2 ];
  #   # };
  #   avahi = { # For finding wireless devices
  #     enable = true;
  #     nssmdns = true;
  #     publish =  {
  #       enable = true;
  #       addresses = true;
  #       userServices = true;
  #     };
  #   };
  #
  #   samba = { # File sharing over local network
  #     enable = true;
  #     shares = {
  #       share = {
  #         "path" = "/home/${vars.user}";
  #         "guest ok" = "yes";
  #         "read only" = "no";
  #       };
  #     };
  #     openFirewall = true;
  #   };
  #
  #   xserver = {
  #     videoDrivers = [ 
  #       # "nvidia" 
  #     ];
  #   };
  #
  # };
}
