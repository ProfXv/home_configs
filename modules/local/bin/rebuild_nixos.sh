#!/bin/sh

sudo cp ~/.config/home-manager/configuration.nix /etc/nixos/configuration.nix
sudo chown root:root /etc/nixos/configuration.nix
sudo nixos-rebuild switch
