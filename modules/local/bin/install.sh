#!/usr/bin/env bash

set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "Error: Must be run as root." && exit 1; }

IS_DISK=false
IS_UEFI=$([ -d /sys/firmware/efi ] && echo true || echo false)

# --- CONFIGURATION ---
EFI_LABEL="fuse"
LVM_LABEL="charge"
LUKS_MAPPER_NAME="enigma"
LVM_VG_NAME="earth"
LV_SWAP="air"
LV_ROOT="sea"
LV_HOME="land"

closest_power_of_2() {
    local target=$1 result=1 prev=0
    while [[ $result -lt $target ]]; do
        prev=$result
        result=$((result * 2))
    done
    [[ $prev -gt 0 && $((target - prev)) -lt $((result - target)) ]] && result=$prev
    echo $result
}

select_device() {
    local type=$1 cmd
    [[ $type == "disk" ]] && {
        cmd="lsblk -ndo NAME,SIZE,MODEL | grep -v '^loop'"
        echo "Available disks:" >&2
    } || {
        cmd="lsblk -nlo NAME,SIZE,FSTYPE -Q 'TYPE==\"part\"' $TARGET"
        echo "Available partitions (0 for whole disk):" >&2
    }
    mapfile -t INFO < <(eval "$cmd")
    NAMES=()
    LABELS=()
    for line in "${INFO[@]}"; do
        read -r col1 col2 col3 <<< "$line"
        NAMES+=("$col1")
        LABELS+=("$col1 ($col2${col3:+, $col3})")
    done
    select ENTRY in "${LABELS[@]}"; do
        [[ $type == "part" && $REPLY =~ ^[0-9]+$ && $REPLY -eq 0 ]] && { IS_DISK=true; break; }
        [[ -n "$ENTRY" ]] && { TARGET="/dev/${NAMES[$((REPLY-1))]}"; break; }
        echo "Invalid selection." >&2
    done
    echo "Selected: $TARGET" >&2
}

for type in disk part; do select_device $type; done

EFI_SIZE="1G"

SIZE_GB=$(( $(lsblk -ndo SIZE -b "$TARGET") / 1024 / 1024 / 1024 ))
ROOT_SIZE=$(closest_power_of_2 $((SIZE_GB / 2)))

MEMORY_GB=$(free -g | awk '/Mem:/ {print $2}')
SWAP_SIZE=$(closest_power_of_2 $MEMORY_GB)

echo "Device: ${SIZE_GB}GB, Calculated root: ${ROOT_SIZE}G, swap: ${SWAP_SIZE}G"
for pair in "Root:ROOT_SIZE" "Swap:SWAP_SIZE"; do
    IFS=: read name var <<< "$pair"
    declare -n ref=$var
    read -p "$name partition size [${ref}G]: " INPUT
    while true; do
        if [[ -z "$INPUT" ]]; then
            ref="${ref}G"; break
        elif [[ "$INPUT" =~ ^[0-9]+$ ]]; then
            select UNIT in P T G M K; do
                [[ -z "$REPLY" ]] && { ref="${INPUT}G"; break 2; }
                [[ -n "$UNIT" ]] && { ref="${INPUT}${UNIT}"; break 2; }
            done
        elif [[ "$INPUT" =~ ^[0-9]+[pPtTgGmMkK]$ ]]; then
            ref="${INPUT^^}"; break
        else
            echo "Invalid format: $INPUT (e.g. 32 or 32G)" >&2
            read -p "$name partition size [${ref}G]: " INPUT
        fi
    done
done

while read -s -p "Enter LUKS encryption password: " ENCRYPT_PASSWORD && echo &&
      read -s -p "Confirm password: " ENCRYPT_PASSWORD_CONFIRM && echo &&
      [[ "$ENCRYPT_PASSWORD" != "$ENCRYPT_PASSWORD_CONFIRM" ]]; do
    echo "Passwords do not match. Please try again."
done

USER="mercury"; read -p "First User [$USER]: " INPUT; USER="${INPUT:-$USER}"

ALL_DESKTOPS=("start-hyprland" "niri")
SELECTED_DESKTOPS=()
AVAILABLE=("${ALL_DESKTOPS[@]}")
echo "Select desktop environments (0 to finish):"
while [[ ${#AVAILABLE[@]} -gt 0 ]]; do
    select DE in "${AVAILABLE[@]}"; do
        [[ "$REPLY" =~ ^[0-9]+$ && "$REPLY" -eq 0 ]] && break 2
        if [[ -n "$DE" ]]; then
            SELECTED_DESKTOPS+=("$DE")
            TMP=()
            for d in "${AVAILABLE[@]}"; do [[ "$d" != "$DE" ]] && TMP+=("$d"); done
            AVAILABLE=("${TMP[@]}")
            break
        fi
    done
done

read SCREEN_WIDTH SCREEN_HEIGHT <<< "$(cat /sys/class/drm/card*-*/modes | head -1 | tr 'x' ' ')"

DESKTOP_JSON=$(printf '%s\n' "${SELECTED_DESKTOPS[@]}" | jq -R . | jq -s .)
jq -n
    --arg user "$USER"
    --argjson width "$SCREEN_WIDTH"
    --argjson height "$SCREEN_HEIGHT"
    --argjson desktops "$DESKTOP_JSON"
    '{username: [$user], screen: {width: $width, height: $height}, desktops: $desktops}'
    > user/.config/home-manager/private/private.json

# --- SCRIPT ---
read -p "This will wipe $TARGET. Continue? (yes/no): " CONFIRMATION
[[ "$CONFIRMATION" = "yes" ]] || { echo "Cancelled." && exit 0; }

cleanup() {
    set +e
    swapoff "/dev/$LVM_VG_NAME/$LV_SWAP" 2>/dev/null
    umount -R /mnt 2>/dev/null
    vgchange -an "$LVM_VG_NAME" 2>/dev/null
    cryptsetup close "$LUKS_MAPPER_NAME" 2>/dev/null
}
trap cleanup EXIT

if $IS_DISK; then
    sgdisk -Z "$TARGET"
    $IS_UEFI && sgdisk -n 1:0:+$EFI_SIZE -t 1:ef00 -c 1:$EFI_LABEL "$TARGET"
    LVM_NUM=$($IS_UEFI && echo 2 || echo 1)
    sgdisk -n $LVM_NUM:0:0 -t $LVM_NUM:8e00 -c $LVM_NUM:$LVM_LABEL "$TARGET"
    partprobe "$TARGET"
    udevadm settle
    $IS_UEFI && EFI="/dev/disk/by-partlabel/$EFI_LABEL"
    LVM="/dev/disk/by-partlabel/$LVM_LABEL"
else
    LVM="$TARGET"
    if $IS_UEFI; then
        disk="/dev/$(lsblk -ndo PKNAME "$TARGET")"
        EFI=$(lsblk -no PATH -Q 'PARTTYPE=~"c12a7328"' "$disk")
        [[ -z "$EFI" ]] && { echo "Error: No EFI partition found." && exit 1; }
        echo "Found EFI partition: $EFI"
    fi
fi

echo -n "$ENCRYPT_PASSWORD" | cryptsetup luksFormat "$LVM" -d -
echo -n "$ENCRYPT_PASSWORD" | cryptsetup open "$LVM" "$LUKS_MAPPER_NAME" -d -

LUKS_DEVICE="/dev/mapper/$LUKS_MAPPER_NAME"

pvcreate "$LUKS_DEVICE"
vgcreate "$LVM_VG_NAME" "$LUKS_DEVICE"
for spec in "$LV_SWAP $SWAP_SIZE -L" "$LV_ROOT $ROOT_SIZE -L" "$LV_HOME 100%FREE -l"; do
    read name size flag <<< "$spec"; lvcreate $flag "$size" -n $name "$LVM_VG_NAME"; done

$IS_DISK && $IS_UEFI && mkfs.fat -F 32 -n $EFI_LABEL "$EFI"
for vol in "$LV_SWAP mkswap" "$LV_ROOT mkfs.btrfs" "$LV_HOME mkfs.btrfs"; do
    read name cmd <<< "$vol"; $cmd -L $name "/dev/$LVM_VG_NAME/$name"; done

mount -o compress=zstd "/dev/$LVM_VG_NAME/${LV_ROOT}" /mnt
mkdir -p /mnt/boot /mnt/home
# 非UEFI模式暂时把磁盘写死，后续修改。
$IS_UEFI && mount "$EFI" /mnt/boot || mount /dev/sda1 /mnt/boot
mount -o compress=zstd "/dev/$LVM_VG_NAME/${LV_HOME}" /mnt/home
swapon "/dev/$LVM_VG_NAME/${LV_SWAP}"

nixos-generate-config --root /mnt
cp user/.config/home-manager/configuration.nix /mnt/etc/nixos
cp -r user/.config/home-manager/private /mnt/etc/nixos
time nixos-install --no-root-passwd

cp -r user/. /mnt/home/$USER/
nixos-enter --root /mnt -- sh -c '
  chown -R "$1:$1" /home/"$1"
  echo "$1:$2" | chpasswd
  nix-daemon &
  su - "$1" -c "home-manager switch"
' _ "$USER" "$ENCRYPT_PASSWORD"
