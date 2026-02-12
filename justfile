# LA-Mesh - Community LoRa Mesh Network for Southern Maine
# ========================================================
#
# Prerequisites:
#   - just (https://github.com/casey/just)
#   - direnv (loads Nix devShell automatically)
#   - Nix with flakes enabled
#
# Quick Start:
#   just setup    # First-time setup
#   just dev      # Start docs dev server
#   just          # List all commands

set dotenv-load := true
set shell := ["bash", "-euo", "pipefail", "-c"]

root := justfile_directory()

# List available commands
default:
    @just --list --unsorted

# =============================================================================
# Setup
# =============================================================================

# First-time setup
setup:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Setting up LA-Mesh development environment..."

    if [ ! -f .env ]; then
        echo "Creating .env from .env.template..."
        cp .env.template .env
        echo "Edit .env with your configuration"
    fi

    cd site && pnpm install
    echo ""
    echo "Setup complete! Run 'just dev' to start the docs server."

# Show environment info
info:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "LA-Mesh Environment"
    echo "==================="
    echo "Node:       $(node --version 2>/dev/null || echo 'not found')"
    echo "pnpm:       $(pnpm --version 2>/dev/null || echo 'not found')"
    echo "Bazel:      $(bazel --version 2>/dev/null | head -1 || echo 'not found')"
    echo "Meshtastic: $(meshtastic --version 2>/dev/null || echo 'not found')"
    echo "esptool:    $(esptool.py version 2>/dev/null | head -1 || echo 'not found')"
    echo "hackrf:     $(hackrf_info 2>/dev/null | head -1 || echo 'not found / not connected')"
    echo "Root:       {{root}}"

# =============================================================================
# Documentation Site
# =============================================================================

# Start docs site dev server
dev:
    cd site && pnpm dev

# Start docs dev server and open browser
dev-open:
    cd site && pnpm dev -- --open

# Build docs site for production
build:
    cd site && DOCS_BASE_PATH=/LA-Mesh pnpm build

# Preview production build
preview: build
    cd site && pnpm preview

# Install site dependencies
site-install:
    cd site && pnpm install

# Type-check the docs site
site-check:
    cd site && pnpm check

# =============================================================================
# Validation
# =============================================================================

# Run all validations
check: fmt-check site-check
    @echo "All checks passed!"

# Run full CI pipeline locally
ci: check build
    @echo "CI simulation complete!"

# =============================================================================
# Meshtastic Device Management
# =============================================================================

# Show connected Meshtastic device info
mesh-info:
    meshtastic --info

# List nodes in the mesh
mesh-nodes:
    meshtastic --nodes

# Send a test message
mesh-send message:
    meshtastic --sendtext "{{message}}"

# Export device config to YAML
mesh-export-config device="":
    #!/usr/bin/env bash
    set -euo pipefail
    DEVICE_FLAG=""
    if [ -n "{{device}}" ]; then
        DEVICE_FLAG="--port {{device}}"
    fi
    meshtastic $DEVICE_FLAG --export-config > configs/devices/export-$(date +%Y%m%d-%H%M%S).yaml
    echo "Config exported to configs/devices/"

# Apply a device profile
mesh-apply-profile profile:
    meshtastic --configure configs/profiles/{{profile}}.yaml

# =============================================================================
# Device Configuration
# =============================================================================

# Apply a device configuration profile (with auto-backup)
configure-profile profile port="/dev/ttyUSB0":
    ./tools/configure/apply-profile.sh {{profile}} {{port}}

# Apply LA-Mesh channel configuration (reads PSK from env vars)
configure-channels port="/dev/ttyUSB0":
    ./tools/configure/apply-channels.sh {{port}}

# Backup device config to configs/backups/
configure-backup port="/dev/ttyUSB0":
    ./tools/configure/backup-config.sh {{port}}

# Factory reset a device (interactive confirmation)
configure-reset port="/dev/ttyUSB0":
    ./tools/configure/factory-reset.sh {{port}}

# =============================================================================
# Firmware
# =============================================================================

# Download and verify firmware for a device (or all devices)
fetch-firmware device="all" version="" *FLAGS="":
    ./tools/flash/fetch-firmware.sh --device {{device}} {{FLAGS}} \
        $([ -n "{{version}}" ] && echo "--version {{version}}" || true)

# One-command device provisioning: fetch + flash + configure + channels
provision device port="/dev/ttyUSB0" *FLAGS="":
    ./tools/flash/provision-device.sh {{device}} {{port}} {{FLAGS}}

# Flash Meshtastic firmware (manual)
flash-meshtastic firmware_file port="/dev/ttyUSB0" *FLAGS="":
    ./tools/flash/flash-meshtastic.sh {{firmware_file}} {{port}} {{FLAGS}}

# Flash MeshCore firmware (manual)
flash-meshcore firmware_file port="/dev/ttyUSB0":
    ./tools/flash/flash-meshcore.sh {{firmware_file}} {{port}}

# Erase ESP32 flash (chip-level factory reset)
flash-erase port="/dev/ttyUSB0":
    esptool.py --chip auto --port {{port}} erase_flash

# Check connected ESP32 device
flash-info port="/dev/ttyUSB0":
    esptool.py --chip auto --port {{port}} chip_id

# Show pinned firmware versions from manifest
firmware-versions:
    @echo "LA-Mesh Firmware Versions"
    @echo "========================="
    @jq -r '"Meshtastic: v" + .meshtastic.version + " (min: v" + .meshtastic.min_version + ")"' firmware/manifest.json
    @jq -r '"MeshCore:   " + .meshcore.version' firmware/manifest.json
    @jq -r '"HackRF:     Mayhem v" + .hackrf.mayhem_version' firmware/manifest.json
    @echo ""
    @echo "Devices:"
    @jq -r '.meshtastic.devices | to_entries[] | "  " + .key + ": " + .value.binary' firmware/manifest.json

# Check for upstream firmware updates
firmware-check:
    #!/usr/bin/env bash
    set -euo pipefail
    CURRENT=$(jq -r '.meshtastic.version' firmware/manifest.json)
    echo "Current pinned version: v$CURRENT"
    echo "Checking GitHub for latest release..."
    LATEST=$(gh api repos/meshtastic/firmware/releases/latest --jq '.tag_name' 2>/dev/null | sed 's/^v//')
    if [ -z "$LATEST" ]; then
        echo "Could not check latest version (gh CLI not authenticated?)"
        exit 1
    fi
    echo "Latest upstream release: v$LATEST"
    if [ "$CURRENT" = "$LATEST" ]; then
        echo "Up to date!"
    else
        echo ""
        echo "UPDATE AVAILABLE: v$CURRENT -> v$LATEST"
        echo "  Release notes: https://github.com/meshtastic/firmware/releases/tag/v$LATEST"
        echo "  Update manifest: just fetch-firmware --version $LATEST"
    fi

# Update SHA256 hashes in manifest after downloading firmware
firmware-update-hashes:
    #!/usr/bin/env bash
    set -euo pipefail
    CACHE_DIR="${FIRMWARE_CACHE_DIR:-firmware/.cache}"
    MANIFEST="firmware/manifest.json"
    for device in $(jq -r '.meshtastic.devices | keys[]' "$MANIFEST"); do
        BINARY=$(jq -r ".meshtastic.devices[\"$device\"].binary" "$MANIFEST")
        FILE="$CACHE_DIR/$BINARY"
        if [ -f "$FILE" ]; then
            HASH=$(sha256sum "$FILE" | cut -d' ' -f1)
            jq ".meshtastic.devices[\"$device\"].sha256 = \"$HASH\"" "$MANIFEST" > "$MANIFEST.tmp"
            mv "$MANIFEST.tmp" "$MANIFEST"
            echo "$device: $HASH"
        else
            echo "$device: not cached (run 'just fetch-firmware' first)"
        fi
    done
    echo ""
    echo "Manifest updated: $MANIFEST"

# Switch firmware between Meshtastic and MeshCore (interactive)
switch-firmware port="/dev/ttyUSB0":
    ./tools/flash/switch-firmware.sh {{port}}

# =============================================================================
# HackRF / Mayhem Firmware
# =============================================================================

# Fetch Mayhem firmware for HackRF H4M
hackrf-fetch-firmware version="":
    #!/usr/bin/env bash
    set -euo pipefail
    MANIFEST="firmware/manifest.json"
    CACHE_DIR="${FIRMWARE_CACHE_DIR:-firmware/.cache}"
    mkdir -p "$CACHE_DIR"
    VER="${1:-$(jq -r '.hackrf.mayhem_version' "$MANIFEST")}"
    BINARY=$(jq -r '.hackrf.files.firmware.binary' "$MANIFEST")
    URL="https://github.com/portapack-mayhem/mayhem-firmware/releases/download/v${VER}/${BINARY}"
    DEST="$CACHE_DIR/$BINARY"
    if [ -f "$DEST" ]; then
        echo "Already cached: $DEST"
    else
        echo "Downloading Mayhem v${VER}..."
        curl -fSL -o "$DEST" "$URL"
        echo "Downloaded: $DEST"
    fi
    # Verify SHA256 if pinned
    EXPECTED=$(jq -r '.hackrf.files.firmware.sha256 // empty' "$MANIFEST")
    if [ -n "$EXPECTED" ] && [ "$EXPECTED" != "UPDATE_WITH_ACTUAL_HASH_AFTER_DOWNLOAD" ]; then
        ACTUAL=$(sha256sum "$DEST" | cut -d' ' -f1)
        if [ "$ACTUAL" != "$EXPECTED" ]; then
            echo "CHECKSUM MISMATCH -- refusing to use!"
            echo "  Expected: $EXPECTED"
            echo "  Actual:   $ACTUAL"
            rm -f "$DEST"
            exit 1
        fi
        echo "Checksum OK: $ACTUAL"
    else
        echo "No hash pinned -- run 'just hackrf-update-hash' to pin."
    fi

# Update HackRF firmware hash in manifest
hackrf-update-hash:
    #!/usr/bin/env bash
    set -euo pipefail
    MANIFEST="firmware/manifest.json"
    CACHE_DIR="${FIRMWARE_CACHE_DIR:-firmware/.cache}"
    BINARY=$(jq -r '.hackrf.files.firmware.binary' "$MANIFEST")
    FILE="$CACHE_DIR/$BINARY"
    if [ ! -f "$FILE" ]; then
        echo "Firmware not cached. Run 'just hackrf-fetch-firmware' first."
        exit 1
    fi
    HASH=$(sha256sum "$FILE" | cut -d' ' -f1)
    jq ".hackrf.files.firmware.sha256 = \"$HASH\"" "$MANIFEST" > "$MANIFEST.tmp"
    mv "$MANIFEST.tmp" "$MANIFEST"
    echo "HackRF Mayhem hash updated: $HASH"

# =============================================================================
# SDR / RF Analysis
# =============================================================================

# Capture LoRa spectrum with HackRF (915 MHz band)
sdr-capture duration="10" output="captures/lora-capture":
    hackrf_transfer -r {{output}}-$(date +%Y%m%d-%H%M%S).raw \
        -f 915000000 -s 2000000 -n $(({{duration}} * 2000000))

# Show HackRF device info
sdr-info:
    hackrf_info

# Prepare HackRF H4M SD card with Mayhem firmware
hackrf-prepare-sd sd_device firmware_archive="":
    ./tools/flash/prepare-hackrf-sd.sh {{sd_device}} {{firmware_archive}}

# =============================================================================
# Nix Commands
# =============================================================================

# Run Nix flake check
nix-check:
    nix flake check

# Update flake inputs
nix-update:
    nix flake update

# Show flake outputs
nix-show:
    nix flake show

# Enter development shell (if not using direnv)
nix-shell:
    nix develop

# Format Nix files
nix-fmt:
    nix fmt

# =============================================================================
# Bazel Commands
# =============================================================================

# Build all Bazel targets
bazel-build:
    bazel build //...

# Run all Bazel tests
bazel-test:
    bazel test //...

# Clean Bazel outputs
bazel-clean:
    bazel clean

# =============================================================================
# Formatting
# =============================================================================

# Format all files
fmt: nix-fmt
    cd site && pnpm format 2>/dev/null || true
    @echo "All files formatted!"

# Check formatting
fmt-check:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Checking Nix formatting..."
    nix fmt -- --check . 2>/dev/null || { echo "Run 'just nix-fmt' to fix"; exit 1; }
    echo "All formatting checks passed!"

# =============================================================================
# Changelog
# =============================================================================

# Generate changelog
changelog:
    git cliff --output CHANGELOG.md

# Preview changelog
changelog-preview:
    git cliff --unreleased

# =============================================================================
# Monitoring
# =============================================================================

# Live MQTT message listener (colored output)
monitor broker="localhost":
    python3 tools/monitor/mqtt-listener.py --broker {{broker}}

# Log MQTT messages to CSV files
monitor-csv broker="localhost" output="logs":
    python3 tools/monitor/mqtt-to-csv.py --broker {{broker}} --output-dir {{output}}

# Live node status dashboard
monitor-nodes broker="localhost":
    python3 tools/monitor/node-status.py --broker {{broker}}

# =============================================================================
# Testing
# =============================================================================

# Run automated range test
test-range count="10" interval="30" port="/dev/ttyUSB0":
    ./tools/test/range-test.sh --count {{count}} --interval {{interval}} --port {{port}}

# Run integration test suite
test-integration port="/dev/ttyUSB0":
    ./tools/test/integration-tests.sh --port {{port}}

# Run a specific integration test
test-one test port="/dev/ttyUSB0":
    ./tools/test/integration-tests.sh --port {{port}} --test {{test}}

# =============================================================================
# Cleanup
# =============================================================================

# Remove build artifacts
clean:
    rm -rf site/build site/.svelte-kit
    rm -rf result result-*

# Deep clean
clean-all: clean bazel-clean
    rm -rf site/node_modules .direnv/
    @echo "Deep clean complete!"
