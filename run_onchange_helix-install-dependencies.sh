#!/bin/bash

# Rerun this script whenever the pnpm-lock.yaml file changes
# pnpm-lock.yaml hash: {{ include dot_config/helix/pnpm-lock.yaml | sha256sum }}
pnpm --dir {{ joinPath .chezmoi.sourceDir "dot_config/helix" | quote }} install