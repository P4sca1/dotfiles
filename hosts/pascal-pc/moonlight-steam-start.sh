#!/usr/bin/env bash
set -xeuo pipefail

kscreen-doctor output.DP-1.mode.1920x1080@60

gamescopeArgs=(
    "--output-width" "1920"
    "--nested-width" "1920"
    "--output-height" "1080"
    "--nested-height" "1080"
)
steamArgs=(
    -pipewire-dmabuf
)

gamescope "${gamescopeArgs[@]}" -- steam "${steamArgs[@]}" steam://open/bigpicture
