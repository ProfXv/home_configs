#!/bin/sh

set -eu

SECRETS_FILE="${HOME}/.config/home-manager/private/secrets.enc.yaml"

sops -d --output-type dotenv "$SECRETS_FILE" | while read -r line; do echo "export $line"; done
