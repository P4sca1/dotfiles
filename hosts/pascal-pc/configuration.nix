{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  hostPlatform = "x86_64-linux";
  nixpkgs-unstable = import inputs.nixpkgs-unstable {
    system = hostPlatform;
  };
in
{
  wsl.enable = true;
  wsl.defaultUser = "pascal";
  wsl.docker-desktop.enable = true;

  programs.zsh.enable = true;
  programs.zsh.shellAliases = {
    op = "/mnt/c/Users/mower/AppData/Local/Microsoft/WinGet/Packages/AgileBits.1Password.CLI_Microsoft.Winget.Source_8wekyb3d8bbwe/op.exe";
  };

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
  ];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.trusted-users = [ "pascal" ];
  nix.gc.automatic = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

  users.users.pascal = {
    description = "Pascal Sthamer";
    shell = pkgs.zsh;
    home = "/home/pascal";
  };

  home-manager.useGlobalPkgs = true;
  home-manager.users.pascal = import ../../home-manager/pascal/home.nix;
  home-manager.extraSpecialArgs = {
    inherit inputs hostPlatform nixpkgs-unstable;
    isWSL = true;
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = hostPlatform;
}
