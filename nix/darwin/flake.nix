{
  description = "Pascal's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-holmesgpt = {
      url = "github:robusta-dev/homebrew-holmesgpt";
      flake = false;
    };

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ self, nix-darwin, ... }:
    let
      hostPlatform = "aarch64-darwin";
      devenv = inputs.devenv.packages.${hostPlatform}.devenv;
      nixpkgs = import inputs.nixpkgs {
        system = hostPlatform;
      };
      allowUnfreePredicate =
        pkg:
        builtins.elem (nixpkgs.lib.getName pkg) [
          "1password"
          "1password-cli"
          "slack"
        ];

      nixpkgs-unstable = import inputs.nixpkgs-unstable {
        system = hostPlatform;
        config.allowUnfreePredicate = allowUnfreePredicate;
      };

      configuration =
        { pkgs, lib, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            pkgs.nixd
            pkgs.nixfmt
            pkgs.nix-init
            devenv
            pkgs.cilium-cli
            pkgs.kubernetes-helm
            pkgs.kubectl
            pkgs.k9s
            pkgs.dive
            pkgs.hcloud
            pkgs.helix
            pkgs.bat
            pkgs.fzf
            pkgs.fd
            pkgs.gh
            pkgs.eza
            pkgs.yq
            pkgs.jsonnet
            pkgs.jsonnet-bundler
            pkgs.regclient
            pkgs.minio-client
            nixpkgs-unstable.element-desktop
            pkgs.glow
            nixpkgs-unstable.zarf
            pkgs.just
            pkgs.manifest-tool
            pkgs.tilt
            pkgs.jsonnet
            pkgs.jsonnet-bundler
            pkgs.wireshark
            # 1password requires to always use the latest version. Otherwise, the password data format
            # might be too new for the app to open and you get an error during app startup.
            nixpkgs-unstable._1password-gui
            nixpkgs-unstable._1password-cli
            pkgs.slack
          ];

          environment.variables = {
            SSH_AUTH_SOCK = "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
          };

          fonts.packages = [
            pkgs.nerd-fonts.jetbrains-mono
          ];

          programs.zsh.enable = true;
          programs.direnv.enable = true;

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";
          nix.settings.trusted-users = [ "pascal" ];
          nix.linux-builder.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # required to use homebrew.enable = true.
          system.primaryUser = "pascal";

          users.users.pascal = {
            description = "Pascal Sthamer";
            shell = pkgs.zsh;
            home = "/Users/pascal";
          };

          home-manager.useGlobalPkgs = true;
          home-manager.users.pascal = { pkgs, ... }: {
            home.packages = [ ];
            home.sessionVariables = {
              EDITOR = "hx";
            };
  
            programs.zsh.enable = true;

            programs.ssh = {
              enable = true;
              enableDefaultConfig = false;
              matchBlocks =
                let
                  opagent = "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
                in
                {
                  "*" = {
                    forwardAgent = false;
                    addKeysToAgent = "no";
                    compression = false;
                    serverAliveInterval = 0;
                    serverAliveCountMax = 3;
                    hashKnownHosts = false;
                    userKnownHostsFile = "~/.ssh/known_hosts";
                    controlMaster = "no";
                    controlPersist = "no";
                    identityAgent = opagent;
                  };
                  "*.teleport.*.*" = {
                    identityAgent = "none";
                  };
               };
            };

            programs.git = {
              enable = true;
              package = pkgs.git;
              settings = {
                user = {
                  email = "pascal+github@sthamer.xyz";
                  name = "Pascal Sthamer";
                };
                init.defaultBranch = "main";
                gpg.ssh = {
                  program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
                };
              };
              signing = {
                format = "ssh";
                key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPyuj6++UcmsipUhtY256OMnj7O+N+26/vA7D57VrnRl";
                signByDefault = true;
              };
              includes = [
                {
                  path  = "~/code/ips/.gitconfig";
                  condition = "gitdir:~/code/ips";
                }
                {
                  path  = "~/code/procyde/.gitconfig";
                  condition = "gitdir:~/code/procyde";
                }
                {
                  path  = "~/code/bwi/.gitconfig";
                  condition = "gitdir:~/code/bwi";
                }
              ];
            };

            programs.alacritty = {
              enable = true;
              package = pkgs.alacritty;
              settings = {};
            };

            # The state version is required and should stay at the version you
            # originally installed.
            home.stateVersion = "25.11";
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
              "visual-studio-code"
              "balenaetcher"
              "bambu-studio"
              "tower"
              "monitorcontrol"
            ];
            masApps = {
              "1Password for Safari" = 1569813296;
              "Yubico Authenticator" = 1497506650;
            };
          };
        };
    in
    {
      # Build darwin flake using:
      # $ sudo darwin-rebuild build --flake .#MacBook-PROCYDE
      darwinConfigurations."MacBook-PROCYDE" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          inputs.nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              # Install Homebrew under the default prefix
              enable = true;

              # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
              enableRosetta = true;

              # User owning the Homebrew prefix
              user = "pascal";

              # Declarative tap management
              taps = {
                "homebrew/homebrew-core" = inputs.homebrew-core;
                "homebrew/homebrew-cask" = inputs.homebrew-cask;
                "robusta-dev/homebrew-holmesgpt" = inputs.homebrew-holmesgpt;
              };

              # Enable fully-declarative tap management
              #
              # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
              mutableTaps = false;
            };
          }
          # Align homebrew taps config with nix-homebrew
          (
            { config, ... }:
            {
              homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
            }
          )
          inputs.home-manager.darwinModules.home-manager
        ];
      };
    };
}
