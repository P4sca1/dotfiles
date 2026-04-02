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

    eurkey = {
      url = "github:felixfoertsch/EurKEY-macOS";
      flake = false;
    };
  };

  outputs =
    inputs@{ self, nix-darwin, ... }:
    let
      hostPlatform = "aarch64-darwin";
      devenv = inputs.devenv.packages.${hostPlatform}.devenv;
      nixpkgs = import inputs.nixpkgs {
        system = hostPlatform;
      };
      nixpkgs-unstable = import inputs.nixpkgs-unstable {
        system = hostPlatform;
        config.allowUnfreePredicate = allowUnfreePredicate;
      };
      allowUnfreePredicate =
        pkg:
        builtins.elem (nixpkgs.lib.getName pkg) [
          "1password"
          "1password-cli"
          "slack"
          "orbstack"
        ];
      eurKeyBundle = nixpkgs.stdenv.mkDerivation {
        name = "EurKEY-Next";

        src = inputs.eurkey;

        nativeBuildInputs = [ nixpkgs.python3 ];

        buildPhase = ''
          WORKDIR=$(mktemp -d)
          cp -r "$src"/* "$WORKDIR/"
          cd "$WORKDIR"
          bash scripts/build-bundle.sh
          mkdir -p "$out"
          mv "$WORKDIR/build/EurKEY-Next.bundle" "$out/"
        '';

        installPhase = ''
          ls -la "$out/"
        '';
      };

      configuration =
        { pkgs, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = [
            pkgs.wireshark
            pkgs.orbstack
            # 1password requires to always use the latest version. Otherwise, the password data format
            # might be too new for the app to open and you get an error during app startup.
            nixpkgs-unstable._1password-gui
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

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # required to use homebrew.enable = true.
          system.primaryUser = "pascal";

          system.defaults = {
            dock.autohide = true;
            finder.FXPreferredViewStyle = "clmw";
            loginwindow.GuestEnabled = false;
            NSGlobalDomain.AppleICUForce24HourTime = true;
          };

          users.users.pascal = {
            description = "Pascal Sthamer";
            shell = pkgs.zsh;
            home = "/Users/pascal";
          };

          home-manager.useGlobalPkgs = true;
          home-manager.users.pascal =
          let
            # Common dependencies for editors, such as language servers or formatters.
            editorDeps = nixpkgs.buildEnv {
              name = "editor-deps";
              paths =[
                # Language Servers
                nixpkgs.typescript-language-server
                nixpkgs.vscode-langservers-extracted
                nixpkgs.tailwindcss-language-server
                nixpkgs.bash-language-server
                nixpkgs.gopls
                nixpkgs.golangci-lint-langserver

                # Formatters / Linters
                nixpkgs.biome
                nixpkgs.prettier
                nixpkgs.shfmt
                nixpkgs.golangci-lint
              ];
            };
          in
          { pkgs, ... }: {
            home.packages = with pkgs; [
              # Dev / Nix tools
              devenv
              nix-init
              nixd
              nixfmt

              # Kubernetes / Cloud / Containers
              cilium-cli
              istioctl
              trivy
              dive
              hcloud
              kubernetes-helm
              kubectl
              manifest-tool
              minio-client
              regclient
              nixpkgs-unstable.zarf

              # CLI utilities
              gh
              glow
              jsonnet
              jsonnet-bundler
              yq
              # 1password requires to always use the latest version. Otherwise, the password data format
              # might be too new for the app to open and you get an error during app startup.
              nixpkgs-unstable._1password-cli
              pnpm
              nodejs
              just

              # GUI apps
              slack
            ];

            home.sessionPath = [
              # Ensure all editor tooling is in PATH, so that vscodium can access language servers and other tooling.
              "${editorDeps}/bin"
            ];

            home.sessionVariables = {
            };

            home.shellAliases = {
              k = "kubectl";
            };

            home.shell.enableShellIntegration = true;

            home.file."Library/Keyboard Layouts/EurKEY-Next.bundle" = {
              source = "${eurKeyBundle}/EurKEY-Next.bundle";
            };

            # The state version is required and should stay at the version you
            # originally installed.
            home.stateVersion = "25.11";

            programs.aerospace = {
              enable = true;
              package = pkgs.aerospace;
              launchd.enable = true;
            };

            programs.alacritty = {
              enable = true;
              package = pkgs.alacritty;
              theme = "github_dark"; # github_light
              settings = {
                window = {
                  opacity = 1.0;
                  decorations = "Full";
                  decorations_theme_variant = "None";
                  padding = {
                    x = 12;
                    y = 12;
                  };
                };
                font = {
                  normal = { family = "JetBrainsMono Nerd Font Mono"; style = "Regular"; };
                  bold = { family = "JetBrainsMono Nerd Font Mono"; style = "Bold"; };
                  italic = { family = "JetBrainsMono Nerd Font Mono"; style = "Italic"; };
                  bold_italic = { family = "JetBrainsMono Nerd Font Mono"; style = "Bold Italic"; };
                  size = 18;
                };
                scrolling = {
                  history = 10000;
                  multiplier = 3;
                };
              };
            };

            programs.bat = {
              enable = true;
              package = pkgs.bat;
            };

            programs.element-desktop = {
              enable = true;
              package = nixpkgs-unstable.element-desktop; # pkgs.element-desktop does not build as of now
            };

            programs.eza = {
              enable = true;
              package = pkgs.eza;
              colors = "auto";
              extraOptions = [
                "--smart-group"
                "--group-directories-first"
                "--icons=auto"
                "--git"
                "--git-repos-no-status"
              ];
            };

            programs.fd = {
              enable = true;
              package = pkgs.fd;
            };

            programs.firefox = {
              enable = true;
              package = pkgs.firefox;
              languagePacks = [
                "en-US"
                "de"
              ];
            };

            programs.fzf = {
              enable = true;
              package = pkgs.fzf;
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
                  program = "${pkgs._1password-gui}/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
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

            programs.helix = {
              enable = true;
              package = pkgs.helix;
              defaultEditor = true;
              ignores = [
                "!.gitignore"
              ];
              settings = {
                theme = "papercolor-dark";
                # This is not supported by Helix in the current release, but is planned.
                # See https://github.com/helix-editor/helix/pull/14356.
                # theme.light = "papercolor-light";
                # theme.dark = "papercolor-dark";
                editor.bufferline = "always";
              };
              languages = {
                javascript = {
                  autoFormat = true;
                  languageServers = [
                    { name = "typescript-language-server"; command = "${editorDeps}/bin/typescript-language-server"; exceptFeatures = ["format"]; }
                    { name = "biome"; command = "${editorDeps}/bin/biome"; }
                  ];
                };

                typescript = {
                  autoFormat = true;
                  languageServers = [
                    { name = "typescript-language-server"; command = "${editorDeps}/bin/typescript-language-server"; exceptFeatures = ["format"]; }
                    { name = "biome"; command = "${editorDeps}/bin/biome"; }
                  ];
                };

                html = {
                  languageServers = [
                    { name = "vscode-html-language-server"; command = "${editorDeps}/bin/vscode-html-language-server"; }
                    { name = "tailwindcss-ls"; command = "${editorDeps}/bin/tailwindcss-ls"; }
                  ];
                };

                css = {
                  languageServers = [
                    { name = "vscode-css-language-server"; command = "${editorDeps}/bin/vscode-css-language-server"; }
                    { name = "tailwindcss-ls"; command = "${editorDeps}/bin/tailwindcss-ls"; }
                  ];
                };

                json = {
                  languageServers = [
                    { name = "vscode-json-language-server"; command = "${editorDeps}/bin/vscode-json-language-server"; exceptFeatures = ["format"]; }
                    { name = "biome"; command = "${editorDeps}/bin/biome"; }
                  ];
                };

                vue = {
                  autoFormat = true;
                  formatter = { command = "${editorDeps}/bin/prettier"; args = ["--parser" "vue"]; };
                  languageServers = [
                    { name = "typescript-language-server"; command = "${editorDeps}/bin/typescript-language-server"; }
                  ];
                  plugins = [
                    { name = "@vue/typescript-plugin"; location = "${editorDeps}/lib/node_modules/@vue/typescript-plugin"; languages = ["vue"]; }
                  ];
                };

                markdown = {
                  autoFormat = true;
                  formatter = { command = "${editorDeps}/bin/dprint"; args = ["fmt" "--stdin" "md"]; };
                };

                go = {
                  autoFormat = true;
                  formatter = { command = "${editorDeps}/bin/goimports"; };
                  languageServers = [
                    { name = "gopls"; command = "${editorDeps}/bin/gopls"; }
                    { name = "golangci-lint-langserver"; command = "${editorDeps}/bin/golangci-lint-langserver"; }
                  ];
                };

                bash = {
                  languageServers = [
                    { name = "bash-language-server"; command = "${editorDeps}/bin/bash-language-server"; }
                  ];
                  formatter = { command = "${editorDeps}/bin/shfmt"; };
                };
              };
            };

            programs.k9s = {
              enable = true;
              package = pkgs.helix;
            };

            programs.mcp = {
              enable = true;
              servers = { };
            };

            programs.opencode = {
              enable = true;
              enableMcpIntegration = true;
              package = pkgs.opencode;
              settings = {
                # Add the procyde provider.
                provider = {
                  procyde = {
                    npm = "@ai-sdk/openai-compatible";
                    name = "Procyde Intelligent Assistant";
                    options = {
                      baseURL = "https://pia.procyde.online/v1";
                      apiKey = "{env:PIA_API_KEY}";
                    };
                    models = {
                      "PIA-1" = {
                        name = "PIA-1";
                      };
                    };
                  };
                };

                # Use PIA-1 by default
                model = "procyde/PIA-1";

                # Do not allow to share conversations externally, as they may contain sensitive information
                share = "disabled";

                # Configure default permissions for OpenCode
                permission = {
                  "*" = "ask";
                  read = {
                    "*" = "allow";
                    "*.env*" = "deny";
                  };
                  edit = "allow";
                  glob = "allow";
                  grep = "allow";
                  list = "allow";
                  bash = {
                    "*" = "ask";
                    op = "deny";
                  };
                  todoread = "allow";
                  todowrite = "allow";
                  external_directory = "deny";
                  doom_loop = "deny";
                  nixos_nix = "allow";
                };
              };
            };

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

            programs.starship = {
              enable = true;
              package = pkgs.starship;
              # Only available in newer versions of home-manager
              # TODO: Enable once switched to nix and home-manager 26.05.
              # presets = [
              #   "nerd-font-symbols"
              # ];
              settings = {
                kubernetes = {
                  disabled = false;
                };
              };
            };

            programs.tmux = {
              enable = true;
            };

            programs.vscode = {
              enable = true;
              package = pkgs.vscodium;
              mutableExtensionsDir = false;
              profiles.default = {
                enableUpdateCheck = false;
                extensions = [
                  pkgs.vscode-extensions.redhat.vscode-yaml
                  pkgs.vscode-extensions.esbenp.prettier-vscode
                  pkgs.vscode-extensions.redhat.ansible
                  pkgs.vscode-extensions.vue.volar
                  pkgs.vscode-extensions.golang.go
                  pkgs.vscode-extensions.prisma.prisma
                  pkgs.vscode-extensions.hashicorp.hcl
                  pkgs.vscode-extensions.biomejs.biome
                  pkgs.vscode-extensions.mikestead.dotenv
                  pkgs.vscode-extensions.github.github-vscode-theme
                  pkgs.vscode-extensions.github.vscode-github-actions
                ];
                userSettings = {
                  "[yaml]" = {
                    "editor.defaultFormatter" = "redhat.vscode-yaml";
                  };
                  "[jsonc]" = {
                    "editor.defaultFormatter" = "vscode.json-language-features";
                  };
                  "[json]" = {
                    "editor.defaultFormatter" = "esbenp.prettier-vscode";
                  };
                  "[helm]" = {
                    "editor.formatOnSave" = false;
                  };

                  # Ansible / Redhat
                  "redhat.telemetry.enabled" = false;
                  "ansible.lightspeed.enabled" = false;

                  # Nix integration
                  "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
                  "nix.formatterPath" = "${pkgs.nixfmt}/bin/nixfmt";
                  "nix.serverSettings" = {
                    "nixd" = {
                      "formatting" = {
                        "command" = [ "${pkgs.nixfmt}/bin/nixfmt" ];
                      };
                    };
                  };

                  # Appearance
                  "window.autoDetectColorScheme" = true;
                  "workbench.colorTheme" = "GitHub Light Default";
                  "workbench.preferredLightColorTheme" = "GitHub Light Default";
                  "workbench.preferredDarkColorTheme" = "GitHub Dark Default";
                  "workbench.iconTheme" = "material-icon-theme";
                  "workbench.sideBar.location" = "right";
                  "editor.fontFamily" = "JetbrainsMono Nerd Font";
                  "editor.fontSize" = 13;
                  "editor.minimap.enabled" = false;

                  # Miscellaneous
                  "editor.formatOnSave" = true;
                  "files.autoSave" = "afterDelay";
                };
              };
            };
  
            programs.zsh.enable = true;
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
            ];
            # TODO: This is no longer working for some reason
            # masApps = {
            #   "1Password for Safari" = 1569813296;
            #   "Yubico Authenticator" = 1497506650;
            #   "Magnet" = 441258766;
            # };
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
