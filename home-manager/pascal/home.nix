{
  lib,
  pkgs,
  config,
  inputs,
  nixpkgs-unstable,
  ...
}@args:
let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

  # Common dependencies for editors, such as language servers or formatters.
  editorDeps = pkgs.buildEnv {
    name = "editor-deps";
    paths = [
      # Languages
      pkgs.go # required by the go vscode extension

      # Language Servers
      pkgs.typescript-language-server
      pkgs.vscode-langservers-extracted
      pkgs.tailwindcss-language-server
      pkgs.bash-language-server
      pkgs.gopls
      pkgs.golangci-lint-langserver
      pkgs.nixd
      pkgs.yaml-language-server
      nixpkgs-unstable.ansible-language-server # not in 25.11 yet

      # Formatters / Linters
      pkgs.biome
      pkgs.prettier
      pkgs.shfmt
      pkgs.golangci-lint
      pkgs.nixfmt
      pkgs.yamlfmt
      pkgs.yamllint
      pkgs.ansible-lint
    ];
  };
in
{
  home.packages =
    let
      sharedPackages = with pkgs; [
        # Dev / Nix tools
        nixpkgs-unstable.devenv # we need at least devenv version 2, which is not part of nixos 25.11
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
        kubespy
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
        pnpm
        nodejs
        just
      ];
      linuxPackages = lib.optionals isLinux (with pkgs; [
      ]);
      darwinPackages = lib.optionals isDarwin (with pkgs; [
        # GUI apps
        slack
      ]);
    in
    sharedPackages ++ linuxPackages ++ darwinPackages;

  home.sessionPath = [
    # Ensure all editor tooling is in PATH, so that vscodium can access language servers and other tooling.
    "${editorDeps}/bin"
  ];

  home.sessionVariables = {
    EDITOR = "hx";
  };

  home.shellAliases = {
    k = "kubectl";
  };

  home.shell.enableShellIntegration = true;

  # Hide last login message when opening a terminal
  home.file.".hushlogin".text = "";

  # home.file."Library/Keyboard Layouts/EurKEY-Next.bundle" = {
  #   source = "${eurKeyBundle}/EurKEY-Next.bundle";
  # };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "25.11";

  xdg.enable = true;

  accounts.email.accounts = {
    "pascal@sthamer.xyz" = {
      primary = true;
      address = "pascal@sthamer.xyz";
      realName = "Pascal Sthamer";
      userName = "pascal@sthamer.xyz";
      thunderbird = {
        enable = true;
        profiles = [ "pascal" ];
      };
      imap = {
        host = "mail.ips-hosting.com";
        port = 993;
        tls.enable = true;
      };
      smtp = {
        host = "mail.ips-hosting.com";
        port = 465;
        tls.enable = true;
      };
    };

    "sthamer.pascal@gmail.com" = {
      address = "sthamer.pascal@gmail.com";
      realName = "Pascal Sthamer";
      userName = "sthamer.pascal@gmail.com";
      thunderbird = {
        enable = true;
        profiles = [ "pascal" ];
      };
      flavor = "gmail.com";
    };

    "pascal.sthamer@ips-hosting.com" = {
      address = "pascal.sthamer@ips-hosting.com";
      realName = "Pascal Sthamer";
      userName = "pascal.sthamer@ips-hosting.com";
      thunderbird = {
        enable = true;
        profiles = [ "pascal" ];
      };
      imap = {
        host = "mail.ips-hosting.com";
        port = 993;
        tls.enable = true;
      };
      smtp = {
        host = "mail.ips-hosting.com";
        port = 465;
        tls.enable = true;
      };
    };

    "pascal.sthamer@einfach-gaming.de" = {
      address = "pascal.sthamer@einfach-gaming.de";
      realName = "Pascal Sthamer";
      userName = "pascal.sthamer@einfach-gaming.de";
      thunderbird = {
        enable = true;
        profiles = [ "pascal" ];
      };
      imap = {
        host = "mail.ips-hosting.com";
        port = 993;
        tls.enable = true;
      };
      smtp = {
        host = "mail.ips-hosting.com";
        port = 465;
        tls.enable = true;
      };
    };
  };

  accounts.calendar.accounts = {
    "pascal@sthamer.xyz" = {
      primary = true;
      remote = {
        type = "caldav";
        url = "https://mail.ips-hosting.com/dav/cal/pascal@sthamer.xyz";
        userName = "pascal@sthamer.xyz";
      };
      thunderbird = {
        enable = true;
        profiles = [ "pascal" ];
      };
    };
  };

  programs.aerospace = lib.mkIf isDarwin {
    enable = true;
    package = pkgs.aerospace;
    launchd.enable = false;
  };

  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty;
    theme = "monokai_charcoal";
    # theme = "papercolor_light";
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
        normal = {
          family = "JetBrainsMono Nerd Font Mono";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font Mono";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font Mono";
          style = "Italic";
        };
        bold_italic = {
          family = "JetBrainsMono Nerd Font Mono";
          style = "Bold Italic";
        };
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

  # element from nixpkgs is not built using element call feature flags.
  # We use the homebrew version instead for now
  # programs.element-desktop = {
  #   enable = true;
  #   package = nixpkgs-unstable.element-desktop; # pkgs.element-desktop does not build as of now
  # };

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
      "de"
      "en-US"
    ];
    nativeMessagingHosts = lib.mkIf isLinux [
      pkgs.kdePackages.plasma-browser-integration
    ];
    profiles = {
      "pascal" = {
        isDefault = true;
        extensions = {
          packages =
            let
              sharedAddons = with pkgs.nur.repos.rycee.firefox-addons; [
                onepassword-password-manager
                ublock-origin
                bypass-paywalls-clean
                auto-reject-cookies
                vue-js-devtools
              ];
              linuxAddons = lib.optionals isLinux (with pkgs.nur.repos.rycee.firefox-addons; [
                plasma-integration
              ]);
              darwinAddons = lib.optionals isDarwin ([ ]);
            in
            sharedAddons ++ linuxAddons ++ darwinAddons;
        };
        bookmarks = {
          force = true;
          settings = [ ];
        };
        search = {
          force = true;
          default = "ddg";
        };
        settings = {
          "extensions.autoDisableScopes" = 0; # Automatically activate extensions.
          "sidebar.verticalTabs" = true;
          "intl.locale.requested" = "de,en-US";

          # AI
          "browser.ai.control.default" = "blocked";

          # Privacy / Telemetry
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "browser.ping-centre.telemetry" = false;
          "app.shield.optoutstudies.enabled" = false;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "datareporting.healthreport.service.enabled" = false;
          "datareporting.sessions.current.clean" = true;
          "devtools.onboarding.telemetry.logged" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.hybridContent.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.prompted" = 2;
          "toolkit.telemetry.rejected" = true;
          "toolkit.telemetry.reportingpolicy.firstRun" = false;
          "toolkit.telemetry.server" = "";
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.unifiedIsOptIn" = false;
          "toolkit.telemetry.updatePing.enabled" = false;

          # Pocket / Sponsored Content
          "extensions.pocket.enabled" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.system.showSponsored" = false;

          # Tracking Protection
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "privacy.partition.network_state" = true;
          "privacy.partition.serviceWorkers" = true;

          # HTTPS / DNS
          "dom.security.https_only_mode" = true;

          # Disable Firefox DoH (use system resolver)
          "network.trr.mode" = 0;

          # Fingerprinting Resistance
          "privacy.resistFingerprinting" = true;

          # Referers
          "network.http.referer.XOriginPolicy" = 2;
          "network.http.referer.XOriginTrimmingPolicy" = 2;

          # Cookies
          "network.cookie.cookieBehavior" = 5;

          # Disable WebRTC IP leaks
          "media.peerconnection.enabled" = false;

          # Search Suggestions
          "browser.search.suggest.enabled" = false;
          "browser.urlbar.suggest.searches" = false;

          # UI annoyances
          "browser.startup.homepage" = "about:home";
          "browser.aboutConfig.showWarning" = false;
          "browser.profiles.enabled" = false;
        };
      };
    };
  };

  programs.thunderbird = {
    enable = isLinux;
    package = pkgs.thunderbird;
    profiles = {
      pascal = {
        isDefault = true;
      };
    };
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
        program =
          if isDarwin then
            "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
          else
            "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      };
    };
    signing = {
      format = "ssh";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPyuj6++UcmsipUhtY256OMnj7O+N+26/vA7D57VrnRl";
      signByDefault = true;
    };
    includes = [
      {
        path = "~/code/ips/.gitconfig";
        condition = "gitdir:~/code/ips/";
      }
      {
        path = "~/code/procyde/.gitconfig";
        condition = "gitdir:~/code/procyde/";
      }
      {
        path = "~/code/bwi/.gitconfig";
        condition = "gitdir:~/code/bwi/";
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
      # theme = "papercolor-dark";
      theme = "papercolor-light";
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
          {
            name = "typescript-language-server";
            command = "${editorDeps}/bin/typescript-language-server";
            exceptFeatures = [ "format" ];
          }
          {
            name = "biome";
            command = "${editorDeps}/bin/biome";
          }
        ];
      };

      typescript = {
        autoFormat = true;
        languageServers = [
          {
            name = "typescript-language-server";
            command = "${editorDeps}/bin/typescript-language-server";
            exceptFeatures = [ "format" ];
          }
          {
            name = "biome";
            command = "${editorDeps}/bin/biome";
          }
        ];
      };

      html = {
        languageServers = [
          {
            name = "vscode-html-language-server";
            command = "${editorDeps}/bin/vscode-html-language-server";
          }
          {
            name = "tailwindcss-ls";
            command = "${editorDeps}/bin/tailwindcss-ls";
          }
        ];
      };

      css = {
        languageServers = [
          {
            name = "vscode-css-language-server";
            command = "${editorDeps}/bin/vscode-css-language-server";
          }
          {
            name = "tailwindcss-ls";
            command = "${editorDeps}/bin/tailwindcss-ls";
          }
        ];
      };

      json = {
        languageServers = [
          {
            name = "vscode-json-language-server";
            command = "${editorDeps}/bin/vscode-json-language-server";
            exceptFeatures = [ "format" ];
          }
          {
            name = "biome";
            command = "${editorDeps}/bin/biome";
          }
        ];
      };

      vue = {
        autoFormat = true;
        formatter = {
          command = "${editorDeps}/bin/prettier";
          args = [
            "--parser"
            "vue"
          ];
        };
        languageServers = [
          {
            name = "typescript-language-server";
            command = "${editorDeps}/bin/typescript-language-server";
          }
        ];
        plugins = [
          {
            name = "@vue/typescript-plugin";
            location = "${editorDeps}/lib/node_modules/@vue/typescript-plugin";
            languages = [ "vue" ];
          }
        ];
      };

      markdown = {
        autoFormat = true;
        formatter = {
          command = "${editorDeps}/bin/dprint";
          args = [
            "fmt"
            "--stdin"
            "md"
          ];
        };
      };

      go = {
        autoFormat = true;
        formatter = {
          command = "${editorDeps}/bin/goimports";
        };
        languageServers = [
          {
            name = "gopls";
            command = "${editorDeps}/bin/gopls";
          }
          {
            name = "golangci-lint-langserver";
            command = "${editorDeps}/bin/golangci-lint-langserver";
          }
        ];
      };

      bash = {
        languageServers = [
          {
            name = "bash-language-server";
            command = "${editorDeps}/bin/bash-language-server";
          }
        ];
        formatter = {
          command = "${editorDeps}/bin/shfmt";
        };
      };

      nix = {
        languageServers = [
          {
            name = "nixd";
            command = "${editorDeps}/bin/nixd";
          }
        ];
        formatter = {
          command = "${editorDeps}/bin/nixfmt";
        };
      };

      yaml = {
        languageServers = [
          {
            name = "yaml-language-server";
            command = "${editorDeps}/bin/yaml-language-server";
          }
          {
            name = "ansible-language-server";
            command = "${editorDeps}/bin/ansible-language-server";
          }
        ];
        formatter = {
          command = "${editorDeps}/bin/yamlfmt";
          args = [ "-" ];
        };
      };
    };
  };

  programs.k9s = {
    enable = true;
    package = pkgs.k9s;
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
        opagent =
          if isDarwin then
            "\"${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\""
          else
            "${config.home.homeDirectory}/.1password/agent.sock";
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
        "*.ips-hosting.com" = {
          user = "ips-hosting";
        };
        "bwi-hetzner-dev" = {
          user = "ubuntu";
          hostname = "168.119.73.177";
          port = 2221;
          localForwards = [
            {
              bind.port = 30080;
              host.address = "localhost";
              host.port = 30080;
            }
            {
              bind.port = 32080;
              host.address = "localhost";
              host.port = 32080;
            }
            {
              bind.port = 32443;
              host.address = "localhost";
              host.port = 32443;
            }
            {
              bind.port = 4711;
              host.address = "localhost";
              host.port = 4711;
            }
          ];
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
        disabled = true;
      };
    };
  };

  programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    clock24 = true;
    escapeTime = 0;
    focusEvents = true;
    historyLimit = 25000;
    aggressiveResize = true;
    baseIndex = 1;
    shortcut = "a";
    keyMode = "vi";
    mouse = true;
    newSession = false;
    secureSocket = true;
    terminal = "screen-256color";
    plugins = [
      pkgs.tmuxPlugins.resurrect
    ];
    sensibleOnTop = true;
    extraConfig = ''
      # Increase tmux messages display duration from 750ms to 4s
      set -g display-time 4000

      # Refresh 'status-left' and 'status-right' more often, from every 15s to 2s
      set -g status-interval 2

      # Emacs key bindings in tmux command prompt (prefix + :) are better than
      # vi keys, even for vim users
      set -g status-keys emacs

      # Easier and faster switching between next/prev window
      bind C-p previous-window
      bind C-n next-window

      # Better pane splitting (and keep current path)
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      # Vim-style pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Vim-style pane resizing
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Bind config using r
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"
    '';
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
        pkgs.vscode-extensions.ms-python.python
        pkgs.vscode-extensions.redhat.ansible
        pkgs.vscode-extensions.vue.volar
        pkgs.vscode-extensions.golang.go
        pkgs.vscode-extensions.prisma.prisma
        pkgs.vscode-extensions.hashicorp.hcl
        pkgs.vscode-extensions.biomejs.biome
        pkgs.vscode-extensions.mikestead.dotenv
        pkgs.vscode-extensions.github.github-vscode-theme
        pkgs.vscode-extensions.github.vscode-github-actions
        pkgs.vscode-extensions.jnoortheen.nix-ide
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
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.formatterPath" = "nixfmt";
        "nix.serverSettings" = {
          "nixd" = {
            "formatting" = {
              "command" = [ "nixfmt" ];
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
}
