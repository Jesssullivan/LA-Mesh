#!/usr/bin/env bash
# LA-Mesh: Guided firmware switch between Meshtastic and MeshCore
# Usage: ./tools/flash/switch-firmware.sh [port]
#
# Interactive script that walks through switching firmware on an ESP32 device.
# Handles backup, erase, flash, and configuration.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

PORT="${1:-/dev/ttyUSB0}"

echo "============================================"
echo "  LA-Mesh Firmware Switcher"
echo "============================================"
echo ""

# Check port
if [ ! -c "$PORT" ]; then
    echo "ERROR: Serial port not found: $PORT"
    echo ""
    echo "Available ports:"
    ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null || echo "  No serial ports detected"
    echo ""
    echo "Usage: $0 [port]"
    exit 1
fi

echo "Port: $PORT"
echo ""

# Detect current firmware
echo "Detecting current firmware..."
CURRENT_FW="unknown"
if meshtastic --port "$PORT" --info &>/dev/null 2>&1; then
    CURRENT_FW="meshtastic"
    FW_VERSION=$(meshtastic --port "$PORT" --info 2>/dev/null | grep -i firmware | head -1 || echo "unknown")
    echo "  Current: Meshtastic ($FW_VERSION)"
else
    echo "  Current: Unknown (possibly MeshCore or blank)"
    echo "  If running MeshCore, detection is not automated."
fi

echo ""
echo "What firmware do you want to switch to?"
echo "  1) Meshtastic (LA-Mesh standard)"
echo "  2) MeshCore (evaluation only)"
echo "  3) Cancel"
echo ""
read -p "Choice [1-3]: " CHOICE

case "$CHOICE" in
    1) TARGET="meshtastic" ;;
    2) TARGET="meshcore" ;;
    3) echo "Cancelled."; exit 0 ;;
    *) echo "Invalid choice."; exit 1 ;;
esac

echo ""
echo "Switching to: $TARGET"
echo ""

# --- Backup if currently Meshtastic ---
if [ "$CURRENT_FW" = "meshtastic" ]; then
    BACKUP_FILE="$ROOT_DIR/configs/backups/pre-switch-$(date +%Y%m%d-%H%M%S).yaml"
    mkdir -p "$(dirname "$BACKUP_FILE")"
    echo "Backing up current Meshtastic config..."
    meshtastic --port "$PORT" --export-config > "$BACKUP_FILE" 2>/dev/null || {
        echo "  WARNING: Could not export config (device may not respond)"
    }
    if [ -f "$BACKUP_FILE" ] && [ -s "$BACKUP_FILE" ]; then
        echo "  Saved: $BACKUP_FILE"
    fi
    echo ""
fi

# --- Confirm ---
echo "This will:"
echo "  1. ERASE all flash memory on the device"
echo "  2. Flash $TARGET firmware"
echo "  3. Apply configuration"
echo ""
echo "All existing data on the device will be LOST."
echo ""
read -p "Continue? (type YES to confirm): " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
    echo "Aborted."
    exit 1
fi

# --- Erase flash ---
echo ""
echo "[1/3] Erasing flash..."
echo "  If device is unresponsive, enter bootloader mode:"
echo "  Hold BOOT button, press RESET, release BOOT"
echo ""

esptool.py --chip auto --port "$PORT" erase_flash || {
    echo ""
    echo "ERROR: Erase failed. Enter bootloader mode and try again."
    exit 1
}
echo ""

# --- Flash firmware ---
echo "[2/3] Flashing $TARGET firmware..."

if [ "$TARGET" = "meshtastic" ]; then
    echo ""
    echo "Which device is this?"
    echo "  1) Station G2 (router/relay)"
    echo "  2) T-Deck / T-Deck Plus (client)"
    echo "  3) T-Deck Pro e-ink (client)"
    echo ""
    read -p "Device [1-3]: " DEVICE_CHOICE

    case "$DEVICE_CHOICE" in
        1) DEVICE="station-g2" ;;
        2) DEVICE="t-deck" ;;
        3) DEVICE="t-deck-pro" ;;
        *) echo "Invalid choice."; exit 1 ;;
    esac

    echo ""
    echo "Provisioning $DEVICE with Meshtastic..."
    "$SCRIPT_DIR/provision-device.sh" "$DEVICE" "$PORT"

elif [ "$TARGET" = "meshcore" ]; then
    echo ""
    echo "MeshCore is best flashed via the web flasher:"
    echo "  https://flasher.meshcore.co.uk"
    echo ""
    echo "The flash has been erased. Open the web flasher in Chrome/Edge,"
    echo "select your device, and flash MeshCore firmware."
    echo ""
    echo "After flashing, configure via:"
    echo "  https://config.meshcore.co.uk"
    echo ""
    echo "[3/3] Configuration: Use the MeshCore web config tool."
    exit 0
fi

echo ""
echo "[3/3] Configuration applied."
echo ""
echo "============================================"
echo "  Firmware switch complete!"
echo "============================================"
echo ""
echo "Verify with: meshtastic --port $PORT --info"
