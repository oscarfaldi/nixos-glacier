{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  ##################################################
  # Boot
  ##################################################

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ##################################################
  # Host
  ##################################################

  networking.hostName = "glacier";

  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Jakarta";

  i18n.defaultLocale = "en_US.UTF-8";

  ##################################################
  # Desktop
  ##################################################

  services.xserver.enable = true;

  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  ##################################################
  # Proxmox / VM Integration
  ##################################################

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  ##################################################
  # User
  ##################################################

  users.users.glacier = {
    isNormalUser = true;
    description = "Glacier";

    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  ##################################################
  # SSH
  ##################################################

  services.openssh = {
    enable = true;

    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  ##################################################
  # Browser
  ##################################################

  programs.firefox.enable = true;

  ##################################################
  # Nix
  ##################################################

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    substituters = [
      "http://localhost:8501"
      "https://cache.nixos.org"
    ];

    trusted-public-keys = [
      "ncps.local:MIxzb9CCWYX8qk2Ec79fKD/d4nvc0anIoEL+A7YJVDE="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  ##################################################
  # NCPS
  ##################################################

  services.ncps = {
    enable = true;

    cache = {
      hostName = "ncps.local";
      maxSize = "50G";
      dataPath = "/var/lib/ncps";
    };

    upstream = {
      caches = [
        "https://cache.nixos.org"
      ];

      publicKeys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
    };
  };

  ##################################################
  # Firewall
  ##################################################

  networking.firewall.allowedTCPPorts = [
    22
    8501
  ];

  ##################################################
  # Packages
  ##################################################

  environment.systemPackages = with pkgs; [
    git
    vim
    nano

    curl
    wget
    jq

    htop
    btop
    fastfetch
    ncdu

    tree
    rsync

    lsof
    pciutils
    usbutils
  ];

  ##################################################
  # Misc
  ##################################################

  nixpkgs.config.allowUnfree = true;

  ##################################################
  # State Version
  ##################################################

  system.stateVersion = "25.11";
}
