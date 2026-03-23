{
  description = "Pascal's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, devenv }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.nixd
          pkgs.nixfmt
          pkgs.nix-init
          devenv.packages.${pkgs.stdenv.hostPlatform.system}.devenv
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
          pkgs.git
          pkgs.jsonnet
          pkgs.jsonnet-bundler
          pkgs.regclient
          pkgs.minio-client
          pkgs.element-desktop
        ];

      programs.direnv.enable = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";
      # ensure reproducible builds
      # nix.settings.sandbox = true;
      # nix.extraOptions = ''
      #   pure-eval = true
      # '';
      # Allow devenv substituter
      nix.settings.trusted-users = ["pascal"];

      # Enable linux builder
      nix.linux-builder.enable = true;

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ sudo darwin-rebuild build --flake .#MacBook-PROCYDE
    darwinConfigurations."MacBook-PROCYDE" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
