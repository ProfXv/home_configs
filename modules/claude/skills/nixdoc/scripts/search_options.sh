#\!/usr/bin/env bash

set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: $0 <nixos|home-manager> <keyword>"
    exit 1
fi

TYPE="$1"
KEYWORD="$2"

case "$TYPE" in
    nixos)
        MAN_PAGE="configuration.nix"
        ;;
    home-manager)
        MAN_PAGE="home-configuration.nix"
        ;;
    *)
        echo "Error: Type must be 'nixos' or 'home-manager'"
        exit 1
        ;;
esac

man "$MAN_PAGE" 2>&1 | \
    grep -i "^\s{7}.*$KEYWORD" | \
    grep '\.' | \
    sed 's/^[[:space:]]*//' | \
    sort -u | \
    head -30
