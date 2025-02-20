# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

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

{ config, pkgs, zap-zsh, inputs, ... }:
let
  stateVersion = "24.11";
  system = "x86_64-linux";
  unstable = import (builtins.fetchTarball { 
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
    sha256 = "1blzcjd13srns4f5b4sl5ad2qqr8wh0p7pxbyl1c15lrsa075v8h";
  }) { system = system; };
  hostname = "znix";
  user = "zedro";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # inputs.home-manager.nixosModules.default
    ];

  # Bootloader.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest; # Get latest kernel
    # Load NVIDIA kernel modules during initrd stage : https://nixos.wiki/wiki/Nvidia
    # initrd.kernelModules = ["nvidia"];
    loader = {
      efi = {
        canTouchEfiVariables = true;
        #efiSysMountPoint = "/boot/efi";
      };
      grub = {
        enable = true;
        device = "nodev"; # "nodev" for EFI
        #efiSupport = true;
        # useOSProber = true;
        configurationLimit = 5; # Limit stored system configs (backups)
      };
      timeout = 5; # Applied to both GRUB and EFI
    };
  };

#  fileSystems."/boot" = {
#    device = "/dev/nvme0n1p1";
#    fsType = "vfat";
#  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ 22 ];
  # networking
  networking = {
    hostName = hostname; # Define your hostname
    networkmanager.enable = true; # Enable networking
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  # Internationalizations (Locales)
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    # keyMap = "qwerty";
  };

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

  # Hardware
  hardware = {
    # Bluetooth Config
    bluetooth = {
      enable = true;
      # hsphfpd.enable = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
    # VIDEO
    graphics = {
        enable = true; # Enable OpenGL
    };
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
      # of just the bare essentials.
      powerManagement.enable = false;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of 
      # supported GPUs is at: 
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
      # Only available from driver 515.43.04+
      open = false;

      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;
    };
    # AUDIO
    pulseaudio.enable = false;
  };


  services = {
    # GUI
    displayManager.defaultSession = "gnome";
    xserver = {
      enable = true; # Enable the X11 windowing system.
      #videoDrivers = ["nvidia"];
      # Enable the GNOME Desktop Environment.
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      xkb = { # Configure keymap in X11
        layout = "us";
        variant = "";
      };
    };
    # Enable CUPS to print documents.
    printing = { 
      enable = true;
    };
    # Enable the OpenSSH daemon.
    openssh = {
      enable = true;
      ports = [ 22 ];
    };
    # Enable mDNS responder to resolve IP addresses
    avahi.enable = true;
  };

  security.rtkit.enable = true;
  # Enable sound with pipewire.
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

  # Set Zsh as default shell for all users
  users.defaultUserShell = pkgs.zsh;
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "Zedro";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "audio" ];
    packages = with pkgs; [
      dwt1-shell-color-scripts
      cowsay
      neo-cowsay
      fortune
      fortune-kind
      clolcat
    ];
  };

  programs.zsh = { # Enable Zsh
    enable = true;
  };

  programs.starship.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils  # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc  # it is a calculator for the IPv4/v6 addresses

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal
    btop  # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring
    stow
    discord
    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb

    # Terminal
    ghostty # Terminal Emulator
    coreutils # GNU Utilities
    xdg-utils # Environment integration
    git
    tmux
    # Shell
    zsh
    # zap-zsh
    nushell
    atuin
    starship
    # Editors
    vim
    unstable.neovim
    # Interpreters
    lua
    luajitPackages.luarocks
    python3Full
    # Compilers
		unstable.clang
    unstable.gcc
    # Build Tools
    gnumake42
    cmake
    # Libs
    llvmPackages_19.libllvm
    libgcc
    libgccjit
    # C/C++
    clang-tools
    codespell
    conan
    cppcheck
    doxygen
    gtest
    lcov
    vcpkg
    vcpkg-tool
    unstable.boost.dev
    unstable.boost
    websocketpp
    # libnghttp2_asio
    unstable.juce
    readline
    # Debug & Heuristics
    valgrind
    gdb
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
    tree
    alejandra
    vlc # Media Player
    cifs-utils # Samba
    appimage-run # Runs AppImages on NixOS
    just # make grand-son

    # Create an FHS environment using the command `fhs`, enabling the execution of non-NixOS packages in NixOS!
    (let base = pkgs.appimageTools.defaultFhsEnvArgs; in
      pkgs.buildFHSUserEnv (base // {
      name = "fhs";
      targetPkgs = pkgs: 
        # pkgs.buildFHSUserEnv provides only a minimal FHS environment,
        # lacking many basic packages needed by most software.
        # Therefore, we need to add them manually.
        #
        # pkgs.appimageTools provides basic packages required by most software.
        (base.targetPkgs pkgs) ++ (with pkgs; [
          pkg-config
          ncurses
        ]
      );
      profile = "export FHS=1";
      runScript = "bash";
      extraOutputsToInstall = ["dev"];
    }))

  ];

  fonts.packages = with pkgs; [
    carlito # NixOS
    vegur # NixOS
    source-code-pro
    jetbrains-mono
    font-awesome # Icons
    corefonts # MS
    noto-fonts # Google + Unicode
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji
  ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = stateVersion; # Did you read the comment?

  # Create Symlinks to interpreters
 #  system.activationScripts.createInterpreterLinks = {
 #    text = ''
 #      if [ ! -e /usr/bin/env ]; then
 #        ln -s /run/current-system/sw/bin/env /usr/bin/env
 #      fi
 #      if [ ! -e /bin/bash ]; then
 #        ln -s /run/current-system/sw/bin/bash /bin/bash
 #      fi
 #    '';
 #  };
  # Create Symlinks to Boost headers
  # system.activationScripts.createBoostHeaderLinks = {
  #   text = ''
  #     BOOST_INCLUDE_DIR="/run/current-system/sw/includes/boost"
  #
  #     if [ ! -e /usr/include/boost ]; then
  #       ln -s $BOOST_INCLUDE_DIR /usr/include/boost
  #     fi
  #   '';
  # };

  # Enable SSH
  services.flatpak.enable = true;

  # Configure Auto System Update
  system.autoUpgrade = {
    enable = true;
    channel = "https://nixos.org/channels/nixos-unstable";
  };

  # Configure Automatic Weekly Garbage Collection
  nix = {
    settings = { 
      auto-optimise-store = true;
      # Enable Flakes
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Overlays (Advanced Biz)
  # nixpkgs.overlays = [
  #   (self: super: {
  #     discord = super.discord.overrideAttrs (
  #       _: { src = builtins.fetchTarball {
  #         url = "http://discord.com/api/download?platform=linux&format=tar.gz";
  #         sha256 = "1lfrnkq7qavlcbyjzn2m8kq39wn82z40dkpn6l5aijy12c775x7s";
  #       }; }
  #     );
  #   })
  # ];
}
