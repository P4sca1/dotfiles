#!/usr/bin/env bash
set -xeuo pipefail

kscreen-doctor output.DP-1.mode.1920x1080@60

gamescopeArgs=(
    --adaptive-sync # VRR support
    --hdr-enabled
    --mangoapp # performance overlay
    --rt
    --steam
    -W 1920
    -H 1080
    -r 60
)
steamArgs=(
    -pipewire-dmabuf
)
mangoConfig=(
    cpu_temp
    gpu_temp
    ram
    vram
)
mangoVars=(
    MANGOHUD=1
    MANGOHUD_CONFIG="$(IFS=,; echo "${mangoConfig[*]}")"
)

export "${mangoVars[@]}"

gamescope "${gamescopeArgs[@]}" -- steam "${steamArgs[@]}" steam://open/bigpicture
