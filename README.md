# dotfiles

Pascal's dotfiles - managed using chezmoi (WIP)

chezmoi docs: https://www.chezmoi.io/user-guide/command-overview/


## Features

- Helix configuration
- Automatic package installation using brew (MacOS)


## Prerequisites

- chezmoi installed

### Darwin (MacOS)

- brew installed

### Windows

- WIP


## Setup a new machine with a single command

`chezmoi init --apply https://github.com/P4sca1/dotfiles.git`


## Helix configuration

### Dependencies

Helix requires language servers and tools like formatters to be installed and available in $PATH.
Dependencies that are available on NPM are managed using a `package.json` in `dot_config/helix/package.json`.
Versions of dependencies are fixed and need to be updated manually.

