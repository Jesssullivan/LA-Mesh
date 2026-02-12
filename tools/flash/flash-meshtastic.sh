#!/usr/bin/env bash
# LA-Mesh: Flash Meshtastic firmware to ESP32 devices
# Usage: ./tools/flash/flash-meshtastic.sh [firmware.bin] [port]
#
# Prerequisites: esptool.py (provided by Nix devShell)
#
# For most users, the web flasher is easier:
#   https://flasher.meshtastic.org
#
# IMPORTANT: Always export config before flashing:
#   meshtastic --export-config > backup-$(date +%Y%m%d).yaml

set -euo pipefail

FIRMWARE="${1:-}"
PORT="${2:-/dev/ttyUSB0}"

if [ -z "$FIRMWARE" ]; then
    echo "LA-Mesh Firmware Flasher"
    echo "========================"
    echo ""
    echo "Usage: $0 <firmware.bin> [port]"
    echo ""
    echo "Arguments:"
    echo "  firmware.bin  Path to Meshtastic firmware binary"
    echo "  port          Serial port (default: /dev/ttyUSB0)"
    echo ""
    echo "Steps:"
    echo "  1. Download firmware from https://meshtastic.org/downloads"
    echo "  2. Choose the correct variant for your device"
    echo "  3. Connect device via USB"
    echo "  4. Run: $0 firmware-<version>.bin"
    echo ""
    echo "Device variants:"
    echo "  station-g2       - Station G2 base station"
    echo "  t-deck           - LilyGo T-Deck / T-Deck Plus"
    echo "  t-deck-pro       - LilyGo T-Deck Pro (e-ink)"
    echo "  rak4631          - RAK WisBlock (nRF52, uses different flash method)"
    echo ""
    echo "For RAK/nRF52 devices, use the Meshtastic web flasher or adafruit-nrfutil."
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

echo "LA-Mesh Firmware Flasher"
echo "========================"
echo "Firmware: $FIRMWARE"
echo "Port:     $PORT"
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
    write_flash \
    0x10000 "$FIRMWARE"

echo ""
echo "Flash complete! Device will reboot."
echo ""
echo "Next steps:"
echo "  1. Apply config profile: meshtastic --configure configs/profiles/<profile>.yaml"
echo "  2. Set channel PSK (get from LA-Mesh admin)"
echo "  3. Verify: meshtastic --info"
