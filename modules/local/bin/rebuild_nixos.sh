#!/bin/sh

ORIGINAL_USER=$(id -un "${SUDO_UID:-$UID}")
HOMEMANAGER_DIR="/home/$ORIGINAL_USER/.config/home-manager"

cp "$HOMEMANAGER_DIR/configuration.nix" /etc/nixos/configuration.nix
cp -r "$HOMEMANAGER_DIR/private" /etc/nixos/
cp -r "$HOMEMANAGER_DIR/overlays" /etc/nixos/
nixos-rebuild switch | less
