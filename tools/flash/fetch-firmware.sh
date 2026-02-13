#!/usr/bin/env bash
# LA-Mesh: Download and verify Meshtastic firmware
# Usage: ./tools/flash/fetch-firmware.sh [--device DEVICE] [--version VERSION] [--source SOURCE]
#
# Downloads firmware from GitHub releases, extracts the correct binary
# for the specified device, and verifies SHA256 checksum.
#
# Source modes:
#   auto     - Use custom LA-Mesh build if available, else upstream (default)
#   custom   - Download custom LA-Mesh build from GitHub Releases
#   upstream - Download stock firmware from meshtastic/firmware releases
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
SOURCE="auto"
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
    echo "  --version VERSION  Override manifest version (e.g., 2.7.15)"
    echo "  --source SOURCE    Firmware source: auto, custom, upstream (default: auto)"
    echo "                     auto: use custom if available, else upstream"
    echo "                     custom: LA-Mesh branded build from GitHub Releases"
    echo "                     upstream: stock from meshtastic/firmware releases"
    echo "  --force            Re-download even if cached"
    echo "  --list             List available devices and exit"
    echo "  -h, --help         Show this help"
    echo ""
    echo "Examples:"
    echo "  $0                                 # Fetch all (auto source)"
    echo "  $0 --source custom                 # Fetch LA-Mesh custom builds"
    echo "  $0 --source upstream               # Fetch stock Meshtastic firmware"
    echo "  $0 --device station-g2             # Fetch Station G2 firmware only"
    echo "  $0 --version 2.7.0 --source upstream  # Specific upstream version"
    exit 0
}

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --device) DEVICE="$2"; shift 2 ;;
        --version) VERSION="$2"; shift 2 ;;
        --source) SOURCE="$2"; shift 2 ;;
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

# Validate source
case "$SOURCE" in
    auto|custom|upstream) ;;
    *) echo "ERROR: Invalid source: $SOURCE (use auto, custom, or upstream)"; exit 1 ;;
esac

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
VERSION_FULL=$(jq -r '.meshtastic.version_full // empty' "$MANIFEST")
if [ -z "$VERSION_FULL" ]; then
    VERSION_FULL="$VERSION"
fi
echo "Firmware version: v$VERSION_FULL"
echo "Source: $SOURCE"

# Create cache directory
mkdir -p "$CACHE_DIR"

# Get list of devices to process
if [ "$DEVICE" = "all" ]; then
    DEVICES=$(jq -r '.meshtastic.devices | keys[]' "$MANIFEST")
else
    if ! jq -e ".meshtastic.devices[\"$DEVICE\"]" "$MANIFEST" &>/dev/null; then
        echo "ERROR: Unknown device: $DEVICE"
        echo "Available devices:"
        jq -r '.meshtastic.devices | keys[]' "$MANIFEST"
        exit 1
    fi
    DEVICES="$DEVICE"
fi

# ── Custom firmware download ────────────────────────────────────────────
# Downloads pre-built LA-Mesh binaries from GitHub Releases.
# These include the custom boot splash and network defaults.
fetch_custom() {
    local dev="$1"
    local custom_url custom_sha custom_bin

    custom_url=$(jq -r ".meshtastic.devices[\"$dev\"].custom.release_url // empty" "$MANIFEST")
    custom_sha=$(jq -r ".meshtastic.devices[\"$dev\"].custom.sha256 // empty" "$MANIFEST")
    custom_bin=$(jq -r ".meshtastic.devices[\"$dev\"].custom.binary // empty" "$MANIFEST")

    if [ -z "$custom_url" ] || [ "$custom_url" = "null" ]; then
        return 1  # No custom build available
    fi

    local dest="$CACHE_DIR/$custom_bin"

    if [ -f "$dest" ] && [ "$FORCE" != "true" ]; then
        echo "  $dev: Using cached custom build: $custom_bin"
    else
        echo "  $dev: Downloading custom LA-Mesh build..."
        echo "    URL: $custom_url"
        if ! curl -fSL --progress-bar -o "$dest" "$custom_url"; then
            echo "    ERROR: Download failed for $dev custom build"
            rm -f "$dest"
            return 1
        fi
    fi

    # Verify SHA256
    if [ -n "$custom_sha" ] && [ "$custom_sha" != "null" ]; then
        local actual_sha
        actual_sha=$(sha256sum "$dest" | cut -d' ' -f1)
        if [ "$actual_sha" = "$custom_sha" ]; then
            echo "  $dev: Custom build OK (SHA256 verified)"
        else
            echo "  $dev: CHECKSUM MISMATCH on custom build!"
            echo "    Expected: $custom_sha"
            echo "    Actual:   $actual_sha"
            return 1
        fi
    else
        echo "  $dev: Custom build downloaded (no checksum in manifest)"
    fi

    local size
    size=$(du -h "$dest" | cut -f1)
    echo "    Binary: $dest ($size)"
    return 0
}

# ── Upstream firmware download ──────────────────────────────────────────
# Downloads stock firmware from meshtastic/firmware GitHub releases.
UPSTREAM_FETCHED=false
fetch_upstream_zips() {
    if [ "$UPSTREAM_FETCHED" = "true" ]; then return; fi

    local chip_families
    if [ "$DEVICE" = "all" ]; then
        chip_families=$(jq -r '.meshtastic.devices[].chip_family_zip // empty' "$MANIFEST" | sort -u)
    else
        chip_families=$(jq -r ".meshtastic.devices[\"$DEVICE\"].chip_family_zip // empty" "$MANIFEST")
    fi
    if [ -z "$chip_families" ]; then
        chip_families="esp32s3"
    fi

    for chip_family in $chip_families; do
        local release_url="https://github.com/meshtastic/firmware/releases/download/v${VERSION_FULL}/firmware-${chip_family}-${VERSION_FULL}.zip"
        local zip_file="$CACHE_DIR/firmware-${chip_family}-${VERSION_FULL}.zip"
        local extract_dir="$CACHE_DIR/firmware-${chip_family}-${VERSION_FULL}"

        if [ -f "$zip_file" ] && [ "$FORCE" != "true" ]; then
            echo "Using cached download: $zip_file"
        else
            echo "Downloading upstream firmware from GitHub..."
            echo "  URL: $release_url"
            echo ""
            if ! curl -fSL --progress-bar -o "$zip_file" "$release_url"; then
                echo ""
                echo "ERROR: Download failed."
                echo "Check that version v$VERSION_FULL exists at:"
                echo "  https://github.com/meshtastic/firmware/releases"
                rm -f "$zip_file"
                exit 1
            fi
            echo "Download complete: $(du -h "$zip_file" | cut -f1)"
        fi

        if [ -d "$extract_dir" ] && [ "$FORCE" != "true" ]; then
            echo "Using cached extraction: $extract_dir"
        else
            echo "Extracting firmware..."
            rm -rf "$extract_dir"
            mkdir -p "$extract_dir"
            unzip -q -o "$zip_file" -d "$extract_dir"
            echo "Extracted to: $extract_dir"
        fi
    done

    UPSTREAM_FETCHED=true
}

fetch_upstream_device() {
    local dev="$1"
    local binary_name expected_sha binary_path

    binary_name=$(jq -r ".meshtastic.devices[\"$dev\"].binary" "$MANIFEST")
    expected_sha=$(jq -r ".meshtastic.devices[\"$dev\"].sha256" "$MANIFEST")

    # Find the binary in extracted chip-family directories
    binary_path=$(find "$CACHE_DIR" -path "*/firmware-*-${VERSION_FULL}/$binary_name" -type f 2>/dev/null | head -1)
    if [ -z "$binary_path" ]; then
        binary_path=$(find "$CACHE_DIR" -maxdepth 1 -name "$binary_name" -type f 2>/dev/null | head -1)
    fi

    if [ -z "$binary_path" ]; then
        echo "  WARNING: Binary not found for $dev: $binary_name"
        return 1
    fi

    local dest="$CACHE_DIR/$binary_name"
    cp "$binary_path" "$dest"

    # Verify SHA256
    if [ "$expected_sha" != "UPDATE_WITH_ACTUAL_HASH_AFTER_DOWNLOAD" ] && [ -n "$expected_sha" ]; then
        local actual_sha
        actual_sha=$(sha256sum "$dest" | cut -d' ' -f1)
        if [ "$actual_sha" = "$expected_sha" ]; then
            echo "  $dev: Upstream OK (SHA256 verified)"
        else
            echo "  $dev: CHECKSUM MISMATCH!"
            echo "    Expected: $expected_sha"
            echo "    Actual:   $actual_sha"
            return 1
        fi
    else
        local actual_sha
        actual_sha=$(sha256sum "$dest" | cut -d' ' -f1)
        echo "  $dev: Upstream downloaded (SHA256: ${actual_sha:0:16}...)"
        echo "    NOTE: No checksum in manifest. Run 'just firmware-update-hashes' to record."
    fi

    local size
    size=$(du -h "$dest" | cut -f1)
    echo "    Binary: $dest ($size)"
    return 0
}

# ── Fetch BLE OTA and LittleFS from upstream (always needed) ───────────
fetch_support_binaries() {
    local dev="$1"
    local bleota littlefs

    bleota=$(jq -r ".meshtastic.devices[\"$dev\"].bleota // empty" "$MANIFEST")
    littlefs=$(jq -r ".meshtastic.devices[\"$dev\"].littlefs // empty" "$MANIFEST")

    for bin_name in $bleota $littlefs; do
        [ -z "$bin_name" ] && continue
        local dest="$CACHE_DIR/$bin_name"
        if [ -f "$dest" ] && [ "$FORCE" != "true" ]; then
            continue  # Already cached
        fi
        # Look in extracted upstream zips
        local found
        found=$(find "$CACHE_DIR" -path "*/firmware-*-${VERSION_FULL}/$bin_name" -type f 2>/dev/null | head -1)
        if [ -n "$found" ]; then
            cp "$found" "$dest"
        fi
    done
}

# ── Main loop ───────────────────────────────────────────────────────────
echo ""
echo "Processing firmware binaries..."
echo ""

ERRORS=0
for dev in $DEVICES; do
    FETCHED=false

    # Try custom source first (if source is auto or custom)
    if [ "$SOURCE" = "custom" ] || [ "$SOURCE" = "auto" ]; then
        if fetch_custom "$dev"; then
            FETCHED=true
        elif [ "$SOURCE" = "custom" ]; then
            echo "  $dev: No custom build available in manifest"
            ERRORS=$((ERRORS + 1))
            continue
        fi
    fi

    # Fall back to upstream (if source is upstream, or auto with no custom)
    if [ "$FETCHED" = "false" ]; then
        fetch_upstream_zips
        if ! fetch_upstream_device "$dev"; then
            ERRORS=$((ERRORS + 1))
            continue
        fi
    fi

    # Always fetch BLE OTA and LittleFS from upstream
    fetch_upstream_zips
    fetch_support_binaries "$dev"
done

echo ""
if [ "$ERRORS" -gt 0 ]; then
    echo "Completed with $ERRORS error(s)."
    exit 1
else
    echo "All firmware binaries ready in: $CACHE_DIR"
    echo ""
    echo "Next steps:"
    echo "  Flash a device:     just flash-g2 /dev/ttyACM0"
    echo "  Provision a device: just provision <device> /dev/ttyACM0"
fi
