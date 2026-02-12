#!/usr/bin/env bash
# LA-Mesh: Flash Meshtastic firmware to ESP32 devices
# Usage: ./tools/flash/flash-meshtastic.sh [firmware.bin] [port] [OPTIONS]
#
# Prerequisites: esptool.py (provided by Nix devShell)
#
# For most users, the web flasher is easier:
#   https://flasher.meshtastic.org
#
# IMPORTANT: Always export config before flashing:
#   meshtastic --export-config > backup-$(date +%Y%m%d).yaml

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
MANIFEST="$ROOT_DIR/firmware/manifest.json"

FIRMWARE="${1:-}"
PORT="${2:-/dev/ttyUSB0}"
FULL_FLASH=true
VERIFY_SHA=true
EXPECTED_SHA=""

# Parse optional flags after positional args
shift 2 2>/dev/null || shift $# 2>/dev/null || true
while [[ $# -gt 0 ]]; do
    case "$1" in
        --update-only) FULL_FLASH=false; shift ;;
        --full-flash) FULL_FLASH=true; shift ;;
        --no-verify) VERIFY_SHA=false; shift ;;
        --sha256) EXPECTED_SHA="$2"; shift 2 ;;
        *) shift ;;
    esac
done

if [ -z "$FIRMWARE" ]; then
    echo "LA-Mesh Firmware Flasher"
    echo "========================"
    echo ""
    echo "Usage: $0 <firmware.bin> [port] [OPTIONS]"
    echo ""
    echo "Arguments:"
    echo "  firmware.bin  Path to Meshtastic firmware binary"
    echo "  port          Serial port (default: /dev/ttyUSB0)"
    echo ""
    echo "Options:"
    echo "  --full-flash    Flash at offset 0x0 (default, full image)"
    echo "  --update-only   Flash at offset 0x260000 (app partition only)"
    echo "  --sha256 HASH   Expected SHA256 hash for verification"
    echo "  --no-verify     Skip SHA256 verification"
    echo ""
    echo "Steps:"
    echo "  1. Download firmware: just fetch-firmware --device station-g2"
    echo "  2. Connect device via USB"
    echo "  3. Run: $0 firmware/.cache/<binary> /dev/ttyUSB0"
    echo ""
    echo "Or use one-command provisioning:"
    echo "  just provision station-g2 /dev/ttyUSB0"
    echo ""
    echo "Device variants:"
    echo "  station-g2       - Station G2 base station"
    echo "  t-deck           - LilyGo T-Deck / T-Deck Plus / T-Deck Pro"
    echo ""
    echo "Web flasher (recommended for beginners):"
    echo "  https://flasher.meshtastic.org"
    exit 1
fi

if [ ! -f "$FIRMWARE" ]; then
    echo "ERROR: Firmware file not found: $FIRMWARE"
    exit 1
fi

if [ ! -c "$PORT" ]; then
    echo "WARNING: Port $PORT not found. Available ports:"
    ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null || echo "  No serial ports detected"
    echo ""
    echo "Ensure device is connected and in bootloader mode."
    echo "For ESP32-S3: Hold BOOT button, press RESET, release BOOT"
    exit 1
fi

# --- SHA256 Verification ---
if [ "$VERIFY_SHA" = "true" ]; then
    ACTUAL_SHA=$(sha256sum "$FIRMWARE" | cut -d' ' -f1)

    # Try to find expected hash from manifest if not provided via --sha256
    if [ -z "$EXPECTED_SHA" ] && [ -f "$MANIFEST" ]; then
        BASENAME=$(basename "$FIRMWARE")
        # Search manifest devices for matching binary name
        EXPECTED_SHA=$(jq -r \
            ".meshtastic.devices[] | select(.binary == \"$BASENAME\") | .sha256" \
            "$MANIFEST" 2>/dev/null || true)
    fi

    if [ -n "$EXPECTED_SHA" ] && [ "$EXPECTED_SHA" != "UPDATE_WITH_ACTUAL_HASH_AFTER_DOWNLOAD" ]; then
        if [ "$ACTUAL_SHA" = "$EXPECTED_SHA" ]; then
            echo "SHA256 verified: ${ACTUAL_SHA:0:16}..."
        else
            echo "ERROR: SHA256 MISMATCH -- refusing to flash!"
            echo "  Expected: $EXPECTED_SHA"
            echo "  Actual:   $ACTUAL_SHA"
            echo ""
            echo "This could indicate a corrupted download or tampered binary."
            echo "Re-download with: just fetch-firmware --force"
            exit 1
        fi
    else
        echo "SHA256: ${ACTUAL_SHA:0:16}... (no manifest hash to verify against)"
    fi
fi

# --- Flash offset ---
if [ "$FULL_FLASH" = "true" ]; then
    FLASH_OFFSET="0x0"
    echo "Flash mode: FULL (offset 0x0)"
else
    FLASH_OFFSET="0x260000"
    echo "Flash mode: UPDATE ONLY (offset 0x260000, app partition)"
fi

echo ""
echo "LA-Mesh Firmware Flasher"
echo "========================"
echo "Firmware: $FIRMWARE"
echo "Port:     $PORT"
echo "Offset:   $FLASH_OFFSET"
echo ""

# Detect chip type
echo "Detecting chip..."
CHIP_INFO=$(esptool.py --port "$PORT" chip_id 2>&1) || {
    echo "ERROR: Could not detect chip. Is the device in bootloader mode?"
    echo "  ESP32-S3: Hold BOOT button, press RESET, release BOOT"
    exit 1
}

if echo "$CHIP_INFO" | grep -q "ESP32-S3"; then
    CHIP="esp32s3"
elif echo "$CHIP_INFO" | grep -q "ESP32-C3"; then
    CHIP="esp32c3"
elif echo "$CHIP_INFO" | grep -q "ESP32"; then
    CHIP="esp32"
else
    echo "WARNING: Unknown chip type. Attempting auto-detect."
    CHIP="auto"
fi

echo "Detected: $CHIP"
echo ""
echo "Flashing firmware..."
echo "DO NOT disconnect the device during this process!"
echo ""

esptool.py \
    --chip "$CHIP" \
    --port "$PORT" \
    --baud 921600 \
    write-flash \
    "$FLASH_OFFSET" "$FIRMWARE"

echo ""
echo "Flash complete! Device will reboot."
echo ""
echo "Next steps:"
echo "  1. Apply config profile: just configure-profile <profile> $PORT"
echo "  2. Apply channels:       just configure-channels $PORT"
echo "  3. Verify:               meshtastic --port $PORT --info"
echo ""
echo "Or use one-command provisioning for fresh devices:"
echo "  just provision <device> $PORT"
