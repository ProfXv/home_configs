#!/usr/bin/env sh

SOURCE_IP=$(ip route get 1 | awk '{print $7}' | head -1)
TARGET_IP="$1"

ssh-copy-id root@$TARGET_IP
scp install.sh post_install.sh root@$TARGET_IP:.
ssh root@$TARGET_IP "ORIGINAL_IP='$SOURCE_IP' sh install.sh"
