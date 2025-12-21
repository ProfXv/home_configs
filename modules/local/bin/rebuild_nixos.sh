#!/bin/sh

cp /home/paradoxist/.config/home-manager/configuration.nix /etc/nixos/configuration.nix
chown root:root /etc/nixos/configuration.nix
nixos-rebuild switch
