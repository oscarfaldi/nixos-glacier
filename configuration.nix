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
      "glacier:UzkmMZRtnjiYaNB/X8Guih4cdla1RDkkNRhJVgeGKCk="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  ##################################################
  # NCPS
  ##################################################

  services.ncps = {
    enable = true;

    cache = {
      hostName = "glacier";
      maxSize = "40G";
      dataPath = "/var/lib/ncps";

      # Allow `nix copy --to` so locally built paths (unfree packages such as
      # obsidian, nvidia-x11, steam and cloudflare-warp) can be pushed here and
      # substituted on every later install instead of being rebuilt from the
      # vendor download each time.
      allowPutVerb = true;

      # Make the signing key explicit instead of auto-generated. If ncps ever
      # regenerated its key, every client trusting glacier:Uzkm... would start
      # rejecting this cache's narinfos while the cache itself looked healthy.
      secretKeyPath = "/var/lib/ncps/config/cache.key";

      # Without a schedule the size limit is never enforced; the store had
      # already grown past 24G on a 59G disk.
      lru.schedule = "0 3 * * *";
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
