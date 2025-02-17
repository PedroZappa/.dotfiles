# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }: 
let
# Import the unstable channel
  unstable = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {};
  hostname = "znix";
in
{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      # inputs.home-manager.nixosModules.default
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = hostname; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.zedro = {
    isNormalUser = true;
    description = "Zedro";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      dwt1-shell-color-scripts
      cowsay
      neo-cowsay
      fortune
      fortune-kind
      clolcat
    ];
  };

  # Install programs.
  programs.zsh.enable = true;
  programs.starship.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    # Terminals
    ghostty
    tmux
    # Shell
    zsh
    nushell
    atuin
    starship
    # Editors
    vim
    unstable.neovim
    # Interpreters
    lua
    luajitPackages.luarocks
    python39
    # Compilers
		clang
    gcc
    # Build Tools
    gnumake42
    # Libs
    llvmPackages_19.libllvm
    libgcc
    boost186
    websocketpp # <boost/asio>
    juce
    readline
    # Debug & Heuristics
    valgrind
    gdb
    cmake
    # Package Managers
    cargo
    uv
    # Web
    google-chrome
    nodejs_23
    wget
    curl
    # Utils
    unzip
    fzf
    ripgrep
    yarn
    bat
    fx
    alejandra
  ];

  # Get Patched Nerd Font
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable mDNS responder to resolve IP addresses
  # services.avahi.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    # ports = [ 22 ];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ 22 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

  # Create Symlinks to interpreters
  system.activationScripts.createInterpreterLinks = {
    text = ''
      if [ ! -e /usr/bin/env ]; then
        ln -s /run/current-system/sw/bin/env /usr/bin/env
      fi
      if [ ! -e /bin/bash ]; then
        ln -s /run/current-system/sw/bin/bash /bin/bash
      fi
    '';
  };

  # Enable SSH
  services.flatpak.enable = true;

  # Configure Auto System Update
  # system.autoUpgrade = {
  #   enable = true;
  # }

  # Configure Automatic Weekly Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

}
