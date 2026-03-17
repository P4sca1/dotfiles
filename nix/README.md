# Nix

## Prerequisites

You need to have the nix package manager installed. See https://nixos.org/download/ for instructions.
[Lix](https://lix.systems/install/) also works.

## Initial installation

```sh
git clone git@github.com:P4sca1/dotfiles.git

nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake /path/to/dotfiles/nix/darwin#MacBook-PROCYDE
```

## Useful commands

```sh
# Update flake lock file
nix flake update

# Rebuild and switch to new configuration
sudo darwin-rebuild switch --flake /path/to/dotfiles/nix/darwin#MacBook-PROCYDE
```
