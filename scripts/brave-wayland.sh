#!/bin/bash

# Optional: use your own path to brave if needed
BRAVE_BIN="/sbin/brave"

# Force Wayland + Vulkan + Hardware Acceleration
env \
  XDG_SESSION_TYPE=wayland \
  MOZ_ENABLE_WAYLAND=1 \
  LIBVA_DRIVER_NAME=radeonsi \
  $BRAVE_BIN \
  --ozone-platform=wayland \
  --enable-features=UseOzonePlatform,WebGPU \
  --use-vulkan \
  --enable-zero-copy \
  --ignore-gpu-blocklist \
  --password-store=basic \
  "$@"

