#!/usr/bin/env bash
# LA-Mesh: Download and verify Meshtastic firmware
# Usage: ./tools/flash/fetch-firmware.sh [--device DEVICE] [--version VERSION]
#
# Downloads firmware from GitHub releases, extracts the correct binary
# for the specified device, and verifies SHA256 checksum.
#
# Firmware is cached in firmware/.cache/ to avoid re-downloading.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
MANIFEST="$ROOT_DIR/firmware/manifest.json"
CACHE_DIR="${FIRMWARE_CACHE_DIR:-$ROOT_DIR/firmware/.cache}"

# Defaults
DEVICE="all"
VERSION=""
FORCE=false

usage() {
    echo "LA-Mesh Firmware Downloader"
    echo "==========================="
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --device DEVICE    Device to fetch firmware for (default: all)"
    echo "                     Devices: station-g2, t-deck, t-deck-pro"
    echo "  --version VERSION  Override manifest version (e.g., 2.6.11)"
    echo "  --force            Re-download even if cached"
    echo "  --list             List available devices and exit"
    echo "  -h, --help         Show this help"
    echo ""
    echo "Examples:"
    echo "  $0                           # Fetch all device firmware"
    echo "  $0 --device station-g2       # Fetch Station G2 firmware only"
    echo "  $0 --version 2.7.0           # Override version"
    exit 0
}

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --device) DEVICE="$2"; shift 2 ;;
        --version) VERSION="$2"; shift 2 ;;
        --force) FORCE=true; shift ;;
        --list)
            echo "Available devices:"
            jq -r '.meshtastic.devices | keys[]' "$MANIFEST"
            exit 0
            ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

# Check dependencies
for cmd in jq curl sha256sum unzip; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "ERROR: Required tool not found: $cmd"
        echo "Install it or enter the Nix dev shell: nix develop"
        exit 1
    fi
done

if [ ! -f "$MANIFEST" ]; then
    echo "ERROR: Firmware manifest not found: $MANIFEST"
    exit 1
fi

# Read version from manifest or override
if [ -z "$VERSION" ]; then
    VERSION=$(jq -r '.meshtastic.version' "$MANIFEST")
fi
echo "Firmware version: v$VERSION"

# Construct download URL
# If version overridden, construct URL dynamically; otherwise use manifest
if [ -n "$VERSION" ]; then
    RELEASE_URL="https://github.com/meshtastic/firmware/releases/download/v${VERSION}/firmware-${VERSION}.zip"
else
    RELEASE_URL=$(jq -r '.meshtastic.release_url' "$MANIFEST")
fi

# Create cache directory
mkdir -p "$CACHE_DIR"

ZIP_FILE="$CACHE_DIR/firmware-${VERSION}.zip"
EXTRACT_DIR="$CACHE_DIR/firmware-${VERSION}"

# Download firmware zip if not cached
if [ -f "$ZIP_FILE" ] && [ "$FORCE" != "true" ]; then
    echo "Using cached download: $ZIP_FILE"
else
    echo "Downloading firmware from GitHub..."
    echo "  URL: $RELEASE_URL"
    echo ""

    if ! curl -fSL --progress-bar -o "$ZIP_FILE" "$RELEASE_URL"; then
        echo ""
        echo "ERROR: Download failed."
        echo "Check that version v$VERSION exists at:"
        echo "  https://github.com/meshtastic/firmware/releases"
        rm -f "$ZIP_FILE"
        exit 1
    fi
    echo "Download complete: $(du -h "$ZIP_FILE" | cut -f1)"
fi

# Extract firmware zip
if [ -d "$EXTRACT_DIR" ] && [ "$FORCE" != "true" ]; then
    echo "Using cached extraction: $EXTRACT_DIR"
else
    echo "Extracting firmware..."
    rm -rf "$EXTRACT_DIR"
    mkdir -p "$EXTRACT_DIR"
    unzip -q -o "$ZIP_FILE" -d "$EXTRACT_DIR"
    echo "Extracted to: $EXTRACT_DIR"
fi

# Get list of devices to process
if [ "$DEVICE" = "all" ]; then
    DEVICES=$(jq -r '.meshtastic.devices | keys[]' "$MANIFEST")
else
    # Validate device name
    if ! jq -e ".meshtastic.devices[\"$DEVICE\"]" "$MANIFEST" &>/dev/null; then
        echo "ERROR: Unknown device: $DEVICE"
        echo "Available devices:"
        jq -r '.meshtastic.devices | keys[]' "$MANIFEST"
        exit 1
    fi
    DEVICES="$DEVICE"
fi

echo ""
echo "Processing firmware binaries..."
echo ""

ERRORS=0
for dev in $DEVICES; do
    BINARY_NAME=$(jq -r ".meshtastic.devices[\"$dev\"].binary" "$MANIFEST")
    EXPECTED_SHA=$(jq -r ".meshtastic.devices[\"$dev\"].sha256" "$MANIFEST")

    # Find the binary in extracted files (may be in subdirectories)
    BINARY_PATH=$(find "$EXTRACT_DIR" -name "$BINARY_NAME" -type f 2>/dev/null | head -1)

    if [ -z "$BINARY_PATH" ]; then
        # Try with version substituted (manifest may have different version)
        ALT_NAME=$(echo "$BINARY_NAME" | sed "s/[0-9]\+\.[0-9]\+\.[0-9]\+/$VERSION/g")
        BINARY_PATH=$(find "$EXTRACT_DIR" -name "$ALT_NAME" -type f 2>/dev/null | head -1)
    fi

    if [ -z "$BINARY_PATH" ]; then
        echo "  WARNING: Binary not found for $dev: $BINARY_NAME"
        echo "  Available binaries:"
        find "$EXTRACT_DIR" -name "*.bin" -type f | sed 's/^/    /' | head -20
        ERRORS=$((ERRORS + 1))
        continue
    fi

    # Copy to cache directory with canonical name
    DEST="$CACHE_DIR/$BINARY_NAME"
    cp "$BINARY_PATH" "$DEST"

    # Verify SHA256 if hash is set (not placeholder)
    if [ "$EXPECTED_SHA" != "UPDATE_WITH_ACTUAL_HASH_AFTER_DOWNLOAD" ] && [ -n "$EXPECTED_SHA" ]; then
        ACTUAL_SHA=$(sha256sum "$DEST" | cut -d' ' -f1)
        if [ "$ACTUAL_SHA" = "$EXPECTED_SHA" ]; then
            echo "  $dev: OK (SHA256 verified)"
        else
            echo "  $dev: CHECKSUM MISMATCH!"
            echo "    Expected: $EXPECTED_SHA"
            echo "    Actual:   $ACTUAL_SHA"
            echo "    This could indicate a corrupted download or tampered binary."
            ERRORS=$((ERRORS + 1))
            continue
        fi
    else
        ACTUAL_SHA=$(sha256sum "$DEST" | cut -d' ' -f1)
        echo "  $dev: Downloaded (SHA256: ${ACTUAL_SHA:0:16}...)"
        echo "    NOTE: No checksum in manifest. Run 'just firmware-update-hashes' to record."
    fi

    SIZE=$(du -h "$DEST" | cut -f1)
    echo "    Binary: $DEST ($SIZE)"
done

echo ""
if [ "$ERRORS" -gt 0 ]; then
    echo "Completed with $ERRORS error(s)."
    exit 1
else
    echo "All firmware binaries ready in: $CACHE_DIR"
    echo ""
    echo "Next steps:"
    echo "  Flash a device:    just flash-meshtastic $CACHE_DIR/<binary> /dev/ttyUSB0"
    echo "  Provision a device: just provision <device> /dev/ttyUSB0"
fi
