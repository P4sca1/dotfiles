{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  hostPlatform = "x86_64-darwin";
  nixpkgs-unstable = import inputs.nixpkgs-unstable {
    system = hostPlatform;
    config.allowUnfreePredicate = allowUnfreePredicate;
  };
  allowUnfreePredicate =
    pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "slack"
      "orbstack"
    ];
  # eurKeyBundle = pkgs.stdenv.mkDerivation {
  #   name = "EurKEY-Next";

  #   src = inputs.eurkey;

  #   nativeBuildInputs = [ pkgs.python3 ];

  #   buildPhase = ''
  #     WORKDIR=$(mktemp -d)
  #     cp -r "$src"/* "$WORKDIR/"
  #     cd "$WORKDIR"
  #     bash scripts/build-bundle.sh
  #     mkdir -p "$out"
  #     mv "$WORKDIR/build/EurKEY-Next.bundle" "$out/"
  #   '';

  #   installPhase = ''
  #     ls -la "$out/"
  #   '';
  # };
in
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.wireshark
    pkgs.orbstack
  ];

  environment.variables = {
    SSH_AUTH_SOCK = "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
  };

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.trusted-users = [ "pascal" ];
  nix.linux-builder.enable = true;
  nix.gc.automatic = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # required to use homebrew.enable = true.
  system.primaryUser = "pascal";

  system.defaults = {
    dock.autohide = true;
    finder.FXPreferredViewStyle = "clmw";
    loginwindow.GuestEnabled = false;
    NSGlobalDomain = {
      AppleICUForce24HourTime = true;
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };
  };

  users.users.pascal = {
    description = "Pascal Sthamer";
    shell = pkgs.zsh;
    home = "/Users/pascal";
  };

  home-manager.useGlobalPkgs = true;
  home-manager.users.pascal = import ../../home-manager/pascal/home.nix;
  home-manager.extraSpecialArgs = {
    inherit inputs hostPlatform nixpkgs-unstable;
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = hostPlatform;
  nixpkgs.config.allowUnfreePredicate = allowUnfreePredicate;

  # Homebrew for packages that are not available via nix
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    brews = [
      "holmesgpt"
    ];
    casks = [
      "deskpad"
      "httpie-desktop"
      "obsidian"
      "setapp"
      "balenaetcher"
      "bambu-studio"
      "tower"
      "monitorcontrol"
      "element"
    ];
    # masApps = {
    #   "1Password for Safari" = 1569813296;
    #   "Yubico Authenticator" = 1497506650;
    #   "Magnet" = 441258766;
    # };
  };
}