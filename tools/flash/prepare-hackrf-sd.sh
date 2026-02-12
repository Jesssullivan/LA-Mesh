#!/usr/bin/env bash
# LA-Mesh: Prepare HackRF H4M / PortaPack SD card with Mayhem firmware
# Usage: ./tools/flash/prepare-hackrf-sd.sh <sd-device> [firmware-archive]
#
# WARNING: This will FORMAT the SD card. All existing data will be lost.
#
# The SD card must be a micro SD card formatted as FAT32.
# The firmware archive should be a .tar or .ppfw.tar from:
#   https://github.com/portapack-mayhem/mayhem-firmware/releases

set -euo pipefail

SD_DEVICE="${1:-}"
FIRMWARE_ARCHIVE="${2:-}"
MOUNT_POINT="/tmp/lamesh-hackrf-sd"

usage() {
    echo "LA-Mesh HackRF SD Card Preparation"
    echo "===================================="
    echo ""
    echo "Usage: $0 <sd-device> [firmware-archive]"
    echo ""
    echo "Arguments:"
    echo "  sd-device          Block device for SD card (e.g., /dev/sdb)"
    echo "  firmware-archive   Mayhem firmware .tar file (optional)"
    echo ""
    echo "Examples:"
    echo "  $0 /dev/sdb mayhem-v2.0.0.tar"
    echo "  $0 /dev/sdb                      # Format only, copy firmware manually"
    echo ""
    echo "WARNING: This will FORMAT the SD card!"
    echo ""
    echo "Download Mayhem firmware:"
    echo "  https://github.com/portapack-mayhem/mayhem-firmware/releases"
    exit 0
}

if [ -z "$SD_DEVICE" ]; then
    usage
fi

# Safety checks
if [ ! -b "$SD_DEVICE" ]; then
    echo "ERROR: Not a block device: $SD_DEVICE"
    echo "List available devices with: lsblk"
    exit 1
fi

# Prevent accidentally formatting system drives
if echo "$SD_DEVICE" | grep -qE "^/dev/(sda|nvme0|vda)"; then
    echo "ERROR: Refusing to format $SD_DEVICE -- this looks like a system drive!"
    echo "SD cards are typically /dev/sdb, /dev/sdc, or /dev/mmcblk0"
    exit 1
fi

echo "LA-Mesh HackRF SD Card Preparation"
echo "===================================="
echo ""
echo "SD Device: $SD_DEVICE"
echo ""

# Show device info
echo "Device info:"
lsblk "$SD_DEVICE" 2>/dev/null || true
echo ""

echo "WARNING: ALL DATA on $SD_DEVICE will be ERASED!"
echo ""
read -p "Continue? (type YES to confirm): " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
    echo "Aborted."
    exit 1
fi

# Determine partition
if echo "$SD_DEVICE" | grep -q "mmcblk"; then
    PARTITION="${SD_DEVICE}p1"
else
    PARTITION="${SD_DEVICE}1"
fi

# Unmount if mounted
echo ""
echo "Unmounting existing partitions..."
umount "${SD_DEVICE}"* 2>/dev/null || true

# Create partition table and FAT32 partition
echo "Creating partition table..."
sudo parted -s "$SD_DEVICE" mklabel msdos
sudo parted -s "$SD_DEVICE" mkpart primary fat32 1MiB 100%

# Format as FAT32
echo "Formatting as FAT32..."
sudo mkfs.vfat -F 32 -n HACKRF "$PARTITION"

# Mount
echo "Mounting..."
mkdir -p "$MOUNT_POINT"
sudo mount "$PARTITION" "$MOUNT_POINT"

# Copy firmware if provided
if [ -n "$FIRMWARE_ARCHIVE" ]; then
    if [ ! -f "$FIRMWARE_ARCHIVE" ]; then
        echo "ERROR: Firmware archive not found: $FIRMWARE_ARCHIVE"
        sudo umount "$MOUNT_POINT"
        exit 1
    fi

    # SHA256 verification against manifest
    MANIFEST="${BASH_SOURCE[0]%/*}/../../firmware/manifest.json"
    if [ -f "$MANIFEST" ] && command -v jq &>/dev/null; then
        EXPECTED_HASH=$(jq -r '.hackrf.files.firmware.sha256 // empty' "$MANIFEST")
        if [ -n "$EXPECTED_HASH" ] && [ "$EXPECTED_HASH" != "UPDATE_WITH_ACTUAL_HASH_AFTER_DOWNLOAD" ]; then
            echo "Verifying SHA256 checksum..."
            ACTUAL_HASH=$(sha256sum "$FIRMWARE_ARCHIVE" | cut -d' ' -f1)
            if [ "$ACTUAL_HASH" != "$EXPECTED_HASH" ]; then
                echo "CHECKSUM MISMATCH -- refusing to flash!"
                echo "  Expected: $EXPECTED_HASH"
                echo "  Actual:   $ACTUAL_HASH"
                echo ""
                echo "Re-download firmware or run: just hackrf-update-hash"
                sudo umount "$MOUNT_POINT"
                exit 1
            fi
            echo "Checksum OK: $ACTUAL_HASH"
        else
            echo "WARNING: No SHA256 hash pinned in manifest -- skipping verification."
            echo "  Run 'just hackrf-update-hash' after downloading firmware."
        fi
    fi

    echo "Extracting firmware..."
    sudo tar -xf "$FIRMWARE_ARCHIVE" -C "$MOUNT_POINT"
    echo "Firmware copied."
fi

# Add LA-Mesh frequency presets
echo "Adding LA-Mesh frequency presets..."
sudo mkdir -p "$MOUNT_POINT/FREQMAN"
sudo tee "$MOUNT_POINT/FREQMAN/la-mesh-915.txt" > /dev/null <<'PRESETS'
f=915000000,d=LoRa 915.0 MHz (Primary)
f=906250000,d=LoRa 906.25 MHz
f=907500000,d=LoRa 907.5 MHz
f=908750000,d=LoRa 908.75 MHz
f=910000000,d=LoRa 910.0 MHz
f=911250000,d=LoRa 911.25 MHz
f=912500000,d=LoRa 912.5 MHz
f=913750000,d=LoRa 913.75 MHz
f=916250000,d=LoRa 916.25 MHz
f=917500000,d=LoRa 917.5 MHz
f=918750000,d=LoRa 918.75 MHz
f=920000000,d=LoRa 920.0 MHz
f=921250000,d=LoRa 921.25 MHz
f=922500000,d=LoRa 922.5 MHz
f=923750000,d=LoRa 923.75 MHz
f=925000000,d=LoRa 925.0 MHz
f=926250000,d=LoRa 926.25 MHz
f=927500000,d=LoRa 927.5 MHz
PRESETS

# Sync and unmount
echo "Syncing..."
sync
sudo umount "$MOUNT_POINT"
rmdir "$MOUNT_POINT" 2>/dev/null || true

echo ""
echo "SD card ready!"
echo ""
echo "Next steps:"
echo "  1. Insert SD card into HackRF H4M PortaPack"
echo "  2. Power on the device"
echo "  3. Firmware loads automatically from SD card"
if [ -z "$FIRMWARE_ARCHIVE" ]; then
    echo ""
    echo "NOTE: No firmware was copied. Download Mayhem firmware and copy to SD card:"
    echo "  https://github.com/portapack-mayhem/mayhem-firmware/releases"
fi
