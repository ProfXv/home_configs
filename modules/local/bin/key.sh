#!/bin/sh

set -euo pipefail

echo "=== Setup Primer Key Partition ==="
echo ""
echo "Available drives:"
lsblk -d -o NAME,SIZE,MODEL,TRAN | grep usb || { echo "No drives detected"; exit 1; }
select DRIVE in $(lsblk -d -n -o NAME,TRAN | grep usb | awk '{print "/dev/"$1}'); do
    [[ -n "$DRIVE" ]] && break || echo "Invalid selection. Please try again."
done
echo "Selected USB: $DRIVE"

umount ${DRIVE}* 2>/dev/null || true

sgdisk -Z "$DRIVE"
sgdisk -n 1:0:+1M -c 1:primer "$DRIVE"
sgdisk -n 2:0:0 -t 2:0700 "$DRIVE"

sleep 1

dd if=/dev/urandom of="${DRIVE}1" bs=4096 count=1 status=none

mkfs.vfat -F 32 "${DRIVE}2" >/dev/null

cryptsetup luksAddKey "/dev/disk/by-partlabel/charge" "${DRIVE}1"

echo "Done!"
lsblk -o NAME,SIZE,PARTLABEL "$DRIVE"
