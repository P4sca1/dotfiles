# P4sca1's Nix config

## Prerequisites

You need to have the nix package manager installed. See https://nixos.org/download/ for instructions.
[Lix](https://lix.systems/install/) also works.

## Initial installation

```sh
git clone git@github.com:P4sca1/nix.git

# NixOS
sudo nixos-rebuild switch --flake /path/to/P4sca1/nix#pascal-pc

# MacOS
sudo nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake /path/to/P4sca1/nix#pascal-mbp
```

## Useful commands

```sh
# Update flake lock file
nix flake update

# NixOS: Rebuild and switch to new configuration
sudo darwin-rebuild switch --flake /path/to/P4sca1/nix#pascal-pc

# MacOS: Rebuild and switch to new configuration
sudo darwin-rebuild switch --flake /path/to/P4sca1/nix#pascal-mbp
```
