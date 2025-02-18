#
#  Main system configuration. More information available in configuration.nix(5) man page.
#
#  flake.nix
#   ├─ ./hosts
#   │   ├─ default.nix
#   │   └─ configuration.nix *
#   └─ ./modules
#       ├─ ./desktops
#       │   └─ default.nix
#       ├─ ./editors
#       │   └─ default.nix
#       ├─ ./hardware
#       │   └─ default.nix
#       ├─ ./programs
#       │   └─ default.nix
#       ├─ ./services
#       │   └─ default.nix
#       ├─ ./shell
#       │   └─ default.nix
#       └─ ./theming
#           └─ default.nix
#

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, stable, inputs, vars, ... }:
let
  system = "x86_64-linux";
  unstable = import (builtins.fetchTarball { 
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
    sha256 = "sha256:1k16pj24gzp3dw76dw1pihij7hh5hic0hkmr00rc5kk4s0c7dqyc";
  }) { system = system; };
  hostname = "znix";
  terminal = pkgs.${vars.terminal};
in
{
  imports =
    [ 
      # ./hardware-configuration.nix
    ];

  # Bootloader.
  boot = {
    tmp = {
      cleanOnBoot = true;
      tmpfsSize = "5GB";
    };
    kernelPackages = pkgs.linuxPackages_latest; # Get latest kernel
    # Load NVIDIA kernel modules during initrd stage : https://nixos.wiki/wiki/Nvidia
    # initrd.kernelModules = ["nvidia"];
    loader = {
      # efi = {
      #   canTouchEfiVariables = true;
      #   efiSysMountPoint = "boot/efi";
      # };
      grub = {
        enable = true;
        device = "/dev/sda";
        # efiSupport = true;
        # useOSProber = true;
        configurationLimit = 5; # Limit stored system configs (backups)
      };
      timeout = 5; # Applied to both GRUB and EFI
    };
  };

  # UEFI
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.canTouchEfiVariables = true;
  # boot.loader = {
  #   efi = {
  #     canTouchEfiVariables = true;
  #     efiSysMountPoint = "/boot/efi";
  #   };
  #   grub = {
  #     enable = true;
  #     devices = ["nodev"];
  #     efiSupport = true;
  #   };
  # };

  # Networking
  # networking = {
  #   hostName = hostname; # Define your hostname
  #   networkmanager.enable = true; # Enable networking
  #   useDHCP = false;
  #   # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  #   # Configure network proxy if necessary
  #   # proxy.default = "http://user:password@proxy:port/";
  #   # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # };

  # Internationalizations (Locales)
  time.timeZone = "Europe/Lisbon";

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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

  # GUI
  services = {
    displayManager.defaultSession = "gnome";
    xserver = {
      enable = true; # Enable the X11 windowing system.
      libinput = {
        enable = true;
      };
      # Enable the GNOME Desktop Environment.
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      xkb = { # Configure keymap in X11
        layout = "us";
        variant = "";
      };
    };
    printing = { # Enable CUPS to print documents.
      enable = true;
    };
    flatpak.enable = true;
  };

  flatpak.enable = true;


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
  };

  # AUDIO
  hardware.pulseaudio.enable = false;
  services = {
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };
    # SSH
    openssh = {
      enable = true;
      allowSFTP = true;
      extraConfig = ''
        HostKeyAlgorithms +ssh-rsa
      '';
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${vars.user} = {
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
      btop
      stow
      discord
    ];
  };

  # Install programs.
  programs.zsh.enable = true;
  programs.starship.enable = true;

  # Allow unfree packages
  # nixpkgs.config.allowUnfree = true;

  fonts.fonts = with pkgs; [
    font-awesome
    (nerdfonts.override {
      fonts = [
        "FiraCode"
      ];
    })
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
  # services.openssh = {
  #   enable = true;
  #   # ports = [ 22 ];
  # };

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

  security = {
    sudo.wheelNeedsPassword = false;
    rtkit.enable = true;
  };


  nix = { # Nix Package Manager Settings
    settings = { 
      # auto-optimise-store = true;
    };
    gc = { # Configure Automatic Weekly Garbage Collection
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    package = pkgs.nixFlakes; # Enable Nix Flakes on the system
    registry.nixpkgs.flake = inputs.nixpkgs;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs          = true
      keep-derivations      = true
    '';
  };

  environment = {
    variables = {
      TERMINAL = "${vars.terminal}";
      EDITOR = "${vars.editor}";
      VISUAL = "${vars.editor}";
    };
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    systemPackages = with pkgs; [
      coreutils # GNU Utilities
      xdg-utils # Environment integration
      killall
      ncdu
      usbutils
      pciutils
      git
      # Terminals
      terminal
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
      # Audio/Video
      alsa-utils # Audio Control
      linux-firmware # Proprietary Hardware Blob
      # Package Managers
      cargo
      uv
      nix-tree # Browse Nix Store
      # Web
      google-chrome
      nodejs_23
      wget
      curl
      # Utils
      appimage-run # Runs AppImages on NixOS
      zip # Zip
      unzip
      unrar # Rar Files
      fzf
      ripgrep
      yarn
      bat
      fx
      vlc # Media Player
      alejandra
      gvfs # Samba
    ] ++
    (with stable; [
      # Apps
      # firefox # Browser
      image-roll # Image Viewer
    ]);
  };
  
  programs = {
  };
  nixpkgs.config.allowUnfree = true;

  home-manager.users.${vars.user} = {
    home = {
      stateVersion = "22.05";
    };
    programs = {
      home-manager.enable = true;
    };
    xdg = {
      mime.enable = true;
      mimeApps = lib.mkIf (config.gnome.enable == false) {
        enable = true;
        defaultApplications = {
          # "image/jpeg" = [ "image-roll.desktop" "feh.desktop" ];
          # "image/png" = [ "image-roll.desktop" "feh.desktop" ];
          # "text/plain" = "nvim.desktop";
          # "text/html" = "nvim.desktop";
          # "text/csv" = "nvim.desktop";
          # "application/pdf" = [ "wps-office-pdf.desktop" "firefox.desktop" "google-chrome.desktop" ];
          # "application/zip" = "org.gnome.FileRoller.desktop";
          # "application/x-tar" = "org.gnome.FileRoller.desktop";
          # "application/x-bzip2" = "org.gnome.FileRoller.desktop";
          # "application/x-gzip" = "org.gnome.FileRoller.desktop";
          # "x-scheme-handler/http" = [ "firefox.desktop" "google-chrome.desktop" ];
          # "x-scheme-handler/https" = [ "firefox.desktop" "google-chrome.desktop" ];
          # "x-scheme-handler/about" = [ "firefox.desktop" "google-chrome.desktop" ];
          # "x-scheme-handler/unknown" = [ "firefox.desktop" "google-chrome.desktop" ];
          # "x-scheme-handler/mailto" = [ "gmail.desktop" ];
          # "audio/mp3" = "mpv.desktop";
          # "audio/x-matroska" = "mpv.desktop";
          # "video/webm" = "mpv.desktop";
          # "video/mp4" = "mpv.desktop";
          # "video/x-matroska" = "mpv.desktop";
          # "inode/directory" = "pcmanfm.desktop";
        };
      };
      desktopEntries.image-roll = {
        name = "image-roll";
        exec = "${stable.image-roll}/bin/image-roll %F";
        mimeType = [ "image/*" ];
      };
      desktopEntries.gmail = {
        name = "Gmail";
        exec = ''xdg-open "https://mail.google.com/mail/?view=cm&fs=1&to=%u"'';
        mimeType = [ "x-scheme-handler/mailto" ];
      };
    };
  };

}
