#!/usr/bin/env bash
set -xeuo pipefail

kscreen-doctor output.DP-1.mode.1920x1080@60

steamArgs=(
    -pipewire-dmabuf
)

steam "${steamArgs[@]}" steam://open/bigpicture
