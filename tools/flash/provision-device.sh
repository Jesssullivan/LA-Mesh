#!/usr/bin/env bash
# LA-Mesh: All-in-one device provisioning
# Usage: ./tools/flash/provision-device.sh <device> <port>
#
# Performs complete device provisioning in one command:
#   1. Fetches firmware if not cached
#   2. Verifies SHA256 checksum
#   3. Flashes firmware to device
#   4. Applies the matching device profile
#   5. Applies LA-Mesh channel configuration
#   6. Verifies device is configured
#
# Requires PSK environment variables:
#   LAMESH_PSK_PRIMARY, LAMESH_PSK_ADMIN, LAMESH_PSK_EMERGENCY

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
MANIFEST="$ROOT_DIR/firmware/manifest.json"
CACHE_DIR="${FIRMWARE_CACHE_DIR:-$ROOT_DIR/firmware/.cache}"

DEVICE="${1:-}"
PORT="${2:-/dev/ttyUSB0}"
SKIP_CHANNELS=false
FLASH_MODE="full"

usage() {
    echo "LA-Mesh Device Provisioner"
    echo "=========================="
    echo ""
    echo "Usage: $0 <device> [port] [OPTIONS]"
    echo ""
    echo "Arguments:"
    echo "  device    Device type: station-g2, t-deck, meshadv-mini"
    echo "  port      Serial port (default: /dev/ttyUSB0)"
    echo ""
    echo "Options:"
    echo "  --skip-channels    Skip channel configuration (apply profile only)"
    echo "  --update-only      Flash app partition only (faster, preserves filesystem)"
    echo "  -h, --help         Show this help"
    echo ""
    echo "Environment variables (required for channel config):"
    echo "  LAMESH_PSK_PRIMARY     Primary channel PSK"
    echo "  LAMESH_PSK_ADMIN       Admin channel PSK"
    echo "  LAMESH_PSK_EMERGENCY   Emergency channel PSK"
    echo ""
    echo "Examples:"
    echo "  $0 station-g2 /dev/ttyUSB0"
    echo "  $0 t-deck /dev/ttyACM0"
    echo "  $0 meshadv-mini              # meshtasticd (no flashing)"
    echo ""
    echo "One-command provisioning:"
    echo "  just provision station-g2 /dev/ttyUSB0"
    exit 0
}

if [ -z "$DEVICE" ]; then
    usage
fi

# Parse remaining args
shift; shift 2>/dev/null || true
while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-channels) SKIP_CHANNELS=true; shift ;;
        --update-only) FLASH_MODE="update"; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

# Header
echo "============================================"
echo "  LA-Mesh Device Provisioner"
echo "============================================"
echo ""
echo "Device:  $DEVICE"
echo "Port:    $PORT"
echo "Mode:    $FLASH_MODE flash"
echo ""

# --- Step 0: Handle meshtasticd (MeshAdv-Mini) separately ---
if [ "$DEVICE" = "meshadv-mini" ]; then
    echo "[1/4] MeshAdv-Mini uses meshtasticd (Linux-native)"
    echo "  Skipping firmware flash -- install via: sudo apt install meshtasticd"
    echo ""

    PROFILE=$(jq -r '.meshtasticd.profile' "$MANIFEST")

    echo "[2/4] Applying profile: $PROFILE"
    "$ROOT_DIR/tools/configure/apply-profile.sh" "$PROFILE" "$PORT"
    echo ""

    if [ "$SKIP_CHANNELS" = "true" ]; then
        echo "[3/4] Skipping channel configuration (--skip-channels)"
    else
        echo "[3/4] Applying LA-Mesh channels..."
        "$ROOT_DIR/tools/configure/apply-channels.sh" "$PORT"
    fi
    echo ""

    echo "[4/4] Verifying configuration..."
    meshtastic --port "$PORT" --info | head -30
    echo ""
    echo "Provisioning complete for $DEVICE!"
    exit 0
fi

# --- Validate device ---
if ! jq -e ".meshtastic.devices[\"$DEVICE\"]" "$MANIFEST" &>/dev/null; then
    echo "ERROR: Unknown device: $DEVICE"
    echo "Available devices:"
    jq -r '.meshtastic.devices | keys[]' "$MANIFEST"
    echo ""
    echo "For MeshAdv-Mini (Raspberry Pi): $0 meshadv-mini"
    exit 1
fi

# --- Check PSK env vars ---
if [ "$SKIP_CHANNELS" != "true" ]; then
    MISSING_VARS=()
    [ -z "${LAMESH_PSK_PRIMARY:-}" ] && MISSING_VARS+=("LAMESH_PSK_PRIMARY")
    [ -z "${LAMESH_PSK_ADMIN:-}" ] && MISSING_VARS+=("LAMESH_PSK_ADMIN")
    [ -z "${LAMESH_PSK_EMERGENCY:-}" ] && MISSING_VARS+=("LAMESH_PSK_EMERGENCY")

    if [ ${#MISSING_VARS[@]} -gt 0 ]; then
        echo "ERROR: Missing required environment variables:"
        for var in "${MISSING_VARS[@]}"; do
            echo "  - $var"
        done
        echo ""
        echo "These PSK values are shared in-person at community meetups."
        echo "Export them from your encrypted keystore before running."
        echo ""
        echo "To skip channel config: $0 $DEVICE $PORT --skip-channels"
        exit 1
    fi
fi

# --- Check serial port ---
if [ ! -c "$PORT" ]; then
    echo "ERROR: Serial port not found: $PORT"
    echo ""
    echo "Available ports:"
    ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null || echo "  No serial ports detected"
    echo ""
    echo "Ensure device is connected via USB data cable."
    exit 1
fi

# --- Step 1: Fetch firmware ---
echo "[1/5] Fetching firmware..."
BINARY_NAME=$(jq -r ".meshtastic.devices[\"$DEVICE\"].binary" "$MANIFEST")
FIRMWARE_PATH="$CACHE_DIR/$BINARY_NAME"

if [ -f "$FIRMWARE_PATH" ]; then
    echo "  Using cached firmware: $FIRMWARE_PATH"
else
    echo "  Downloading firmware..."
    "$SCRIPT_DIR/fetch-firmware.sh" --device "$DEVICE"
fi

if [ ! -f "$FIRMWARE_PATH" ]; then
    echo "ERROR: Firmware binary not found after fetch: $FIRMWARE_PATH"
    exit 1
fi
echo ""

# --- Step 2: Verify checksum ---
echo "[2/5] Verifying firmware integrity..."
EXPECTED_SHA=$(jq -r ".meshtastic.devices[\"$DEVICE\"].sha256" "$MANIFEST")
ACTUAL_SHA=$(sha256sum "$FIRMWARE_PATH" | cut -d' ' -f1)

if [ "$EXPECTED_SHA" != "UPDATE_WITH_ACTUAL_HASH_AFTER_DOWNLOAD" ] && [ -n "$EXPECTED_SHA" ]; then
    if [ "$ACTUAL_SHA" = "$EXPECTED_SHA" ]; then
        echo "  SHA256 verified: ${ACTUAL_SHA:0:16}..."
    else
        echo "  CHECKSUM MISMATCH -- refusing to flash!"
        echo "  Expected: $EXPECTED_SHA"
        echo "  Actual:   $ACTUAL_SHA"
        echo ""
        echo "  Re-download with: just fetch-firmware --device $DEVICE --force"
        exit 1
    fi
else
    echo "  SHA256: ${ACTUAL_SHA:0:16}... (no manifest hash to verify against)"
    echo "  WARNING: Update manifest hashes with: just firmware-update-hashes"
fi
echo ""

# --- Step 3: Flash firmware ---
echo "[3/5] Flashing firmware to $DEVICE on $PORT..."
echo "  DO NOT disconnect the device!"
echo ""

CHIP=$(jq -r ".meshtastic.devices[\"$DEVICE\"].chip" "$MANIFEST")
BAUD=$(jq -r ".meshtastic.devices[\"$DEVICE\"].baud" "$MANIFEST")

if [ "$FLASH_MODE" = "full" ]; then
    OFFSET=$(jq -r ".meshtastic.devices[\"$DEVICE\"].flash_offset_full" "$MANIFEST")
else
    OFFSET=$(jq -r ".meshtastic.devices[\"$DEVICE\"].flash_offset_app" "$MANIFEST")
fi

esptool.py \
    --chip "$CHIP" \
    --port "$PORT" \
    --baud "$BAUD" \
    write_flash \
    "$OFFSET" "$FIRMWARE_PATH"

echo ""
echo "  Flash complete. Waiting for device reboot..."
sleep 5
echo ""

# --- Step 4: Apply profile ---
echo "[4/5] Applying device profile..."
PROFILE=$(jq -r ".meshtastic.devices[\"$DEVICE\"].profile" "$MANIFEST")
echo "  Profile: $PROFILE"

# Wait for device to become responsive
RETRIES=0
MAX_RETRIES=6
while ! meshtastic --port "$PORT" --info &>/dev/null; do
    RETRIES=$((RETRIES + 1))
    if [ "$RETRIES" -ge "$MAX_RETRIES" ]; then
        echo "  ERROR: Device not responding after flash. It may need manual reboot."
        echo "  Try: Press the RESET button, then re-run without flashing:"
        echo "    just configure-profile $PROFILE $PORT"
        exit 1
    fi
    echo "  Waiting for device... (attempt $RETRIES/$MAX_RETRIES)"
    sleep 5
done

"$ROOT_DIR/tools/configure/apply-profile.sh" "$PROFILE" "$PORT"
echo ""

# --- Step 5: Apply channels ---
if [ "$SKIP_CHANNELS" = "true" ]; then
    echo "[5/5] Skipping channel configuration (--skip-channels)"
else
    echo "[5/5] Applying LA-Mesh channels..."
    "$ROOT_DIR/tools/configure/apply-channels.sh" "$PORT"
fi
echo ""

# --- Summary ---
echo "============================================"
echo "  Provisioning Complete!"
echo "============================================"
echo ""
echo "Device:   $DEVICE"
echo "Firmware: v$(jq -r '.meshtastic.version' "$MANIFEST")"
echo "Profile:  $PROFILE"
echo "Channels: $([ "$SKIP_CHANNELS" = "true" ] && echo "skipped" || echo "configured")"
echo ""
echo "Verify with: meshtastic --port $PORT --info"
