#!/usr/bin/env bash
# LA-Mesh: Flash MeshCore firmware to ESP32 devices
# Usage: ./tools/flash/flash-meshcore.sh [firmware.bin] [port]
#
# For most users, the web flasher is easier:
#   https://flasher.meshcore.co.uk
#
# MeshCore firmware variants:
#   companion_radio  - End-user device (connects to phone app)
#   simple_repeater  - Infrastructure relay node
#   simple_room_server - BBS-style server

set -euo pipefail

FIRMWARE="${1:-}"
PORT="${2:-/dev/ttyUSB0}"

if [ -z "$FIRMWARE" ]; then
    echo "LA-Mesh MeshCore Flasher"
    echo "========================"
    echo ""
    echo "Usage: $0 <firmware.bin> [port]"
    echo ""
    echo "MeshCore firmware types:"
    echo "  companion_radio    - Companion device (BLE to phone)"
    echo "  simple_repeater    - Relay/repeater node"
    echo "  simple_room_server - Room server (BBS)"
    echo ""
    echo "Download firmware:"
    echo "  https://github.com/meshcore-dev/MeshCore/releases"
    echo ""
    echo "Web flasher (recommended):"
    echo "  https://flasher.meshcore.co.uk"
    echo ""
    echo "Web config (for repeater setup):"
    echo "  https://config.meshcore.dev"
    exit 1
fi

if [ ! -f "$FIRMWARE" ]; then
    echo "ERROR: Firmware file not found: $FIRMWARE"
    exit 1
fi

echo "Flashing MeshCore firmware: $FIRMWARE"
echo "Port: $PORT"
echo ""

esptool.py \
    --chip auto \
    --port "$PORT" \
    --baud 921600 \
    write_flash \
    0x0 "$FIRMWARE"

echo ""
echo "Flash complete!"
echo ""
echo "Configure via:"
echo "  - Web config: https://config.meshcore.dev (USB)"
echo "  - BLE app: MeshCore companion app"
