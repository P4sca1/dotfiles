# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  inputs,
  hostPlatform,
  ...
}:
let
  nixpkgs-unstable = import inputs.nixpkgs-unstable {
    system = hostPlatform;
  };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelModules = [
    # ntsync is a kernel driver that mimics Windows synchronization mechanisms, significantly improving performance
    # for running Windows applications, especially games, through compatibility layers like Wine and Proton
    "ntsync"
  ];

  networking.hostName = "pascal-pc";
  networking.wireless.enable = true;
  networking.networkmanager.enable = true;
  networking.nftables.enable = true;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "de_DE.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "eu";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.trusted-users = [ "pascal" ];
  nix.gc.automatic = true;

  home-manager.useGlobalPkgs = true;
  home-manager.users.pascal = import ../../home-manager/pascal/home.nix;
  home-manager.extraSpecialArgs = {
    inherit inputs hostPlatform nixpkgs-unstable;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pascal = {
    isNormalUser = true;
    description = "Pascal Sthamer";
    extraGroups = [
      "networkmanager"
      "wheel"
      "gamemode" # https://wiki.nixos.org/wiki/GameMode
      "input"
    ];
    shell = pkgs.zsh;
    home = "/home/pascal";
  };

  programs.zsh.enable = true;

  programs.firefox.enable = true;

  programs.steam = {
    enable = true;
    package = pkgs.steam;
    gamescopeSession = {
      enable = false;
      env = {
        PROTON_USE_NTSYNC = "1";
      };
    };
    extraCompatPackages = with pkgs; [
      # Proton GE for improved game support
      proton-ge-bin
    ];
    localNetworkGameTransfers.openFirewall = true;
    remotePlay.openFirewall = true;
  };

  programs.gamescope = {
    enable = false;
    package = pkgs.gamescope;
    capSysNice = false;
    args = [
      "--rt"
      "--mangoapp"
      "--expose-wayland"
      "--force-grab-cursor"
      "--output-width 3840"
      "--nested-width 3840"
      "--output-height 1600"
      "--nested-height 1600"
      "--fullscreen"
    ];
  };

  # https://github.com/NixOS/nixpkgs/issues/351516#issuecomment-2607156591
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-cpp;
    extraRules = [
      {
        "name" = "gamescope";
        "nice" = -20;
      }
    ];
  };

  programs.gamemode.enable = true;

  programs._1password = {
    enable = true;
    package = pkgs._1password-cli;
  };

  programs._1password-gui = {
    enable = true;
    package = pkgs._1password-gui;
    # Certain features, including CLI integration and system authentication support,
    # require enabling PolKit integration on some desktop environment
    polkitPolicyOwners = [ "pascal" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "1password"
      "1password-cli"
      "nvidia-kernel-modules"
      "nvidia-settings"
      "nvidia-x11"
      "onepassword-password-manager" # firefox extension
      "steam"
      "steam-unwrapped"
      "uhk-agent"
      "uhk-udev-rules"
    ];

  nixpkgs.config.permittedInsecurePackages = [
    "qtwebengine-5.15.19" # used by TeamSpeak 3 client
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    mangohud
    pciutils
    uhk-agent
    vulkan-tools
  ];

  environment.sessionVariables = {
  };

  services.sunshine = {
    enable = true;
    package = pkgs.sunshine;
    openFirewall = true;
    autoStart = true;
    capSysAdmin = true;
    applications = {
      apps = [
        {
          name = "Steam";
          prep-cmd = [
            {
              do = "sudo -u pascal steam -pipewire-dmabuf steam://open/bigpicture";
              undo = "sudo -u pascal steam steam://close/bigpicture";
            }
          ];
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
          image-path = "steam.png";
        }
      ];
    };
    settings = {
      global_prep_cmd = builtins.toJSON [
        {
          do = "kscreen-doctor output.DP-1.mode.1920x1080@60";
          undo = "kscreen-doctjor output.DP-1.mode.3840x1600@75";
        }
      ];
    };
  };

  # Enable flatpack for packages that are not available via nix (e.g. teamspeak3)
  services.flatpak = {
    enable = true;
    package = pkgs.flatpak;
    packages = [
      "com.teamspeak.TeamSpeak3"
    ];
  };

  # Open ports in the firewall.
  networking.firewall.enable = true;

  virtualisation.waydroid.enable = true; # Android virtualization
  virtualisation.podman.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
