#!/usr/bin/env bash

if [ -f ./shell.nix ]; then
    if [ "$1" = "-c" ]; then
        shift 1
        nix-shell --run "$*"
    else
        nix-shell --run "bash $*"
    fi
else
    bash "$@"
fi
