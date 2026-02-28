#!/usr/bin/env bash

iface=$(ip -brief addr | awk '$2!="DOWN" && $1!="lo"' | fzf | awk '{print $1}')
if [[ "$iface" == tailscale* ]]; then
    status=$(tailscale status)
    default_host=$(echo "$status" | awk 'NR==1{print $2}')
    mirror_host=$(echo "$status" | awk '$5!~/offline/' | fzf | awk '{print $2}')
    mirror_host=${mirror_host:-$default_host}
else
    default_host=$(hostname)
    read -rp "Host: " mirror_host
    mirror_host=${mirror_host:-$default_host}
fi
default_user=$(
    [[ "$mirror_host" == "$default_host" ]] &&
    echo "$USER" | rev ||
    echo "$USER"
)
read -rp "User [$default_user]: " mirror_user
mirror_user=${mirror_user:-$default_user}

options=$(
    rsync -h |
    awk '/^--/ && !/=/' |
    fzf -m --prompt="rsync options: " --bind "start:select-all" --query="^--dry" |
    awk '{print $1}' | tr -d ',' | tr '\n' ' '
)
mount_dir=$(mktemp -d)
chosen=$(mktemp)
trap 'fusermount -u "$mount_dir"; rmdir "$mount_dir"; rm -f "$chosen"' EXIT
sshfs "$mirror_user@$mirror_host:" "$mount_dir" || exit 1
yazi --chooser-file="$chosen" "$mount_dir/.config/home-manager"
mapfile -t paths < "$chosen"
paths=("${paths[@]/#$mount_dir\/}")
test ${#paths[@]} -eq 0 && paths=(".config/home-manager")

for path in "${paths[@]}"; do
  src="$mirror_user@$mirror_host:$path"
  dst="$HOME/$path"
  filter=()
  [ "$path" = ".config/home-manager" ] && filter=('--exclude=private/')
  mkdir -p "$(dirname "$dst")"
  rsync -av --chown=$USER:$USER $options "${filter[@]}" "$src" "$(dirname "$dst")/"
done | less
