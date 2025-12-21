#!/bin/sh

set -euo pipefail

# --- CONFIGURATION ---
echo "Available disks:"
lsblk -nd -o NAME,SIZE,MODEL
DISKS=($(lsblk -nd -o NAME | grep -v loop))
select DISK in "${DISKS[@]}"; do
    if [[ -n "$DISK" ]]; then
        TARGET_DISK="$DISK"
        break
    else
        echo "Invalid selection. Please try again."
    fi
done
echo "Selected disk: /dev/${TARGET_DISK}"

EFI_PART_SIZE="1G"
MEMORY_SIZE_KB=$(free | grep Mem: | awk '{print $2}')
MEMORY_SIZE_GB=$(( (MEMORY_SIZE_KB + 1024*1024 - 1) / (1024*1024) ))
SWAP_SIZE=1
while [ $SWAP_SIZE -lt $MEMORY_SIZE_GB ]; do
    SWAP_SIZE=$((SWAP_SIZE * 2))
done
SWAP_SIZE="${SWAP_SIZE}G"
echo "Detected memory: ${MEMORY_SIZE_GB}GB; Calculated swap size: ${SWAP_SIZE}"
ROOT_SIZE="64G"
LUKS_MAPPER_NAME="enigma"
LVM_VG_NAME="earth"

# --- SCRIPT ---
if [[ $EUID -ne 0 ]]; then echo "Error: Must be run as root." && exit 1; fi
if ! lsblk -nd -o NAME "/dev/${TARGET_DISK}" > /dev/null 2>&1; then echo "Error: Disk /dev/${TARGET_DISK} not found." && exit 1; fi
read -p "This will wipe /dev/${TARGET_DISK}. Continue? (yes/no): " CONFIRMATION
if [[ "$CONFIRMATION" != "yes" ]]; then echo "Cancelled." && exit 0; fi

echo "Enter LUKS encryption password:"
read -s ENCRYPT_PASSWORD
echo "Confirm password:"
read -s ENCRYPT_PASSWORD_CONFIRM
if [[ "$ENCRYPT_PASSWORD" != "$ENCRYPT_PASSWORD_CONFIRM" ]]; then echo "Error: Passwords do not match." && exit 1; fi

sgdisk -Z "/dev/${TARGET_DISK}"
sgdisk -n 1:0:+${EFI_PART_SIZE} -t 1:ef00 -c 1:fuse "/dev/${TARGET_DISK}"
sgdisk -n 2:0:0 -t 2:8e00 -c 2:charge "/dev/${TARGET_DISK}"
partprobe "/dev/${TARGET_DISK}"
sleep 2

EFI_PART="/dev/disk/by-partlabel/fuse"
LVM_PART="/dev/disk/by-partlabel/charge"

echo -n "$ENCRYPT_PASSWORD" | cryptsetup luksFormat "$LVM_PART" -d -
echo -n "$ENCRYPT_PASSWORD" | cryptsetup open "$LVM_PART" "$LUKS_MAPPER_NAME" -d -

LUKS_DEVICE="/dev/mapper/${LUKS_MAPPER_NAME}"

pvcreate "$LUKS_DEVICE"
vgcreate "$LVM_VG_NAME" "$LUKS_DEVICE"
lvcreate -L "$SWAP_SIZE" -n air "$LVM_VG_NAME"
lvcreate -L "$ROOT_SIZE" -n sea "$LVM_VG_NAME"
lvcreate -l '100%FREE' -n land "$LVM_VG_NAME"

mkfs.fat -F 32 -n fuse "$EFI_PART"
mkswap -L air "/dev/${LVM_VG_NAME}/air"
mkfs.btrfs -L sea "/dev/${LVM_VG_NAME}/sea"
mkfs.btrfs -L land "/dev/${LVM_VG_NAME}/land"

mount -o compress=zstd "/dev/${LVM_VG_NAME}/sea" /mnt
mkdir -p /mnt/boot /mnt/home
mount "$EFI_PART" /mnt/boot
mount -o compress=zstd "/dev/${LVM_VG_NAME}/land" /mnt/home
swapon "/dev/${LVM_VG_NAME}/air"

ORIGINAL_IP=`cat ip.txt`
ssh-keygen -t ed25519
ssh-copy-id paradoxist@$ORIGINAL_IP
scp paradoxist@$ORIGINAL_IP:Downloads/Wolfram_14.3.0_LIN_Bndl.sh .
nix-store --add-fixed sha256 Wolfram_14.3.0_LIN_Bndl.sh
scp paradoxist@$ORIGINAL_IP:Downloads/WeChatLinux_x86_64.AppImage .
nix-store --add-fixed sha256 WeChatLinux_x86_64.AppImage
nixos-generate-config --root /mnt
scp paradoxist@$ORIGINAL_IP:.config/home-manager/configuration.nix /mnt/etc/nixos
vim /mnt/etc/nixos/configuration.nix
nixos-install --no-root-passwd \
    --option substituters "https://mirror.sjtu.edu.cn/nix-channels/store https://cache.nixos.org"

mkdir /mnt/home/paradoxist/.config
scp -r paradoxist@$ORIGINAL_IP:.config/home-manager /mnt/home/paradoxist/.config
scp -r paradoxist@$ORIGINAL_IP:.python /mnt/home/paradoxist
scp -r paradoxist@$ORIGINAL_IP:* /mnt/home/paradoxist
nixos-enter --root /mnt -- chown -R paradoxist:paradoxist /home/paradoxist

umount -R /mnt
swapoff -a
