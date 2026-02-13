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

# Detect the first available serial port (ttyACM0 preferred, then ttyUSB0)
[private]
detect-port:
    #!/usr/bin/env bash
    set -euo pipefail
    for p in /dev/ttyACM0 /dev/ttyACM1 /dev/ttyUSB0 /dev/ttyUSB1; do
        if [ -c "$p" ]; then echo "$p"; exit 0; fi
    done
    echo "ERROR: No serial port found. Connect a device via USB." >&2
    exit 1

# List available serial ports
ports:
    #!/usr/bin/env bash
    echo "Serial ports:"
    ls -1 /dev/ttyACM* /dev/ttyUSB* 2>/dev/null || echo "  None detected"
    echo ""
    echo "USB devices:"
    lsusb 2>/dev/null | grep -iE "espres|cp210|ch340|ftdi|station|meshtastic" || echo "  No recognized devices"

# Show connected Meshtastic device info
mesh-info port="":
    #!/usr/bin/env bash
    set -euo pipefail
    PORT="{{port}}"
    if [ -z "$PORT" ]; then PORT=$(just detect-port); fi
    meshtastic --port "$PORT" --info

# List nodes in the mesh
mesh-nodes port="":
    #!/usr/bin/env bash
    set -euo pipefail
    PORT="{{port}}"
    if [ -z "$PORT" ]; then PORT=$(just detect-port); fi
    meshtastic --port "$PORT" --nodes

# Send a test message
mesh-send message port="":
    #!/usr/bin/env bash
    set -euo pipefail
    PORT="{{port}}"
    if [ -z "$PORT" ]; then PORT=$(just detect-port); fi
    meshtastic --port "$PORT" --sendtext "{{message}}"

# Export device config to YAML
mesh-export-config port="":
    #!/usr/bin/env bash
    set -euo pipefail
    PORT="{{port}}"
    if [ -z "$PORT" ]; then PORT=$(just detect-port); fi
    mkdir -p configs/devices
    meshtastic --port "$PORT" --export-config > configs/devices/export-$(date +%Y%m%d-%H%M%S).yaml
    echo "Config exported to configs/devices/"

# Apply a device profile
mesh-apply-profile profile port="":
    #!/usr/bin/env bash
    set -euo pipefail
    PORT="{{port}}"
    if [ -z "$PORT" ]; then PORT=$(just detect-port); fi
    meshtastic --port "$PORT" --configure configs/profiles/{{profile}}.yaml

# Set device owner name and short name
mesh-set-owner owner short port="":
    #!/usr/bin/env bash
    set -euo pipefail
    PORT="{{port}}"
    if [ -z "$PORT" ]; then PORT=$(just detect-port); fi
    meshtastic --port "$PORT" --set-owner "{{owner}}" --set-owner-short "{{short}}"
    echo "Owner set: {{owner}} ({{short}})"

# =============================================================================
# Device Configuration
# =============================================================================

# Apply a device configuration profile (with auto-backup)
configure-profile profile port="":
    #!/usr/bin/env bash
    set -euo pipefail
    PORT="{{port}}"
    if [ -z "$PORT" ]; then PORT=$(just detect-port); fi
    ./tools/configure/apply-profile.sh {{profile}} "$PORT"

# Apply LA-Mesh channel configuration (reads PSK from env vars)
configure-channels port="":
    #!/usr/bin/env bash
    set -euo pipefail
    PORT="{{port}}"
    if [ -z "$PORT" ]; then PORT=$(just detect-port); fi
    ./tools/configure/apply-channels.sh "$PORT"

# Complete post-flash configuration for Station G2 (LoRa + channels + owner)
configure-g2 owner="LA-Mesh RTR-01" short="R01" port="":
    #!/usr/bin/env bash
    set -euo pipefail
    PORT="{{port}}"
    if [ -z "$PORT" ]; then PORT=$(just detect-port); fi

    echo "Station G2 Post-Flash Configuration"
    echo "===================================="
    echo "Port:  $PORT"
    echo "Owner: {{owner}} ({{short}})"
    echo ""

    # Check PSK env vars
    MISSING=()
    [ -z "${LAMESH_PSK_PRIMARY:-}" ] && MISSING+=("LAMESH_PSK_PRIMARY")
    [ -z "${LAMESH_PSK_ADMIN:-}" ] && MISSING+=("LAMESH_PSK_ADMIN")
    [ -z "${LAMESH_PSK_EMERGENCY:-}" ] && MISSING+=("LAMESH_PSK_EMERGENCY")
    if [ ${#MISSING[@]} -gt 0 ]; then
        echo "ERROR: Missing PSK environment variables:"
        for v in "${MISSING[@]}"; do echo "  - $v"; done
        echo ""
        echo "Generate with: just generate-psks"
        echo "Then export the values and re-run."
        exit 1
    fi

    # Wait for device to be ready (ESP32-S3 native USB drops on every reboot)
    wait_ready() {
        local attempt=0
        while ! meshtastic --port "$PORT" --info &>/dev/null; do
            attempt=$((attempt + 1))
            if [ "$attempt" -ge 6 ]; then
                echo "  ERROR: Device not responding after 60s."
                echo "  Try: unplug and replug USB, then re-run."
                exit 1
            fi
            echo "  Waiting for device... (attempt $attempt/6)"
            sleep 10
        done
    }

    # --- Step 1: LoRa radio settings ---
    echo "[1/6] Configuring LoRa radio..."
    wait_ready
    meshtastic --port "$PORT" \
        --set lora.region US \
        --set lora.modem_preset LONG_FAST \
        --set lora.hop_limit 5 \
        --set lora.tx_power 30 \
        --set lora.sx126x_rx_boosted_gain true
    sleep 20

    # --- Step 2: Device settings (NOT role -- that's last) ---
    echo "[2/6] Configuring device settings..."
    wait_ready
    meshtastic --port "$PORT" \
        --set device.serial_enabled true \
        --set device.rebroadcast_mode ALL \
        --set device.node_info_broadcast_secs 10800
    sleep 20

    # --- Step 3: Display, bluetooth, security ---
    echo "[3/6] Configuring display, bluetooth, security..."
    wait_ready
    meshtastic --port "$PORT" \
        --set display.screen_on_secs 31536000 \
        --set bluetooth.enabled true \
        --set security.serial_enabled true \
        --set security.admin_channel_enabled true
    sleep 20

    # --- Step 4: Channels ---
    echo "[4/6] Configuring channels..."
    wait_ready
    ./tools/configure/apply-channels.sh "$PORT"

    # --- Step 5: Owner name ---
    echo "[5/6] Setting owner name..."
    wait_ready
    meshtastic --port "$PORT" \
        --set-owner "{{owner}}" \
        --set-owner-short "{{short}}"
    sleep 10

    # --- Step 6: Verify ---
    echo "[6/6] Verifying configuration..."
    wait_ready
    meshtastic --port "$PORT" --info 2>&1 | grep -E "(Owner|firmwareVersion|hwModel|role|Channels:|Index)" || true
    echo ""
    echo "============================================"
    echo "  Configuration Complete!"
    echo "============================================"
    echo ""
    echo "Owner:    {{owner}} ({{short}})"
    echo "Role:     CLIENT (set ROUTER as final step)"
    echo "Channels: 3 configured (LA-Mesh, LA-Admin, LA-Emergcy)"
    echo ""
    echo "FINAL STEP -- set ROUTER role (kills USB serial):"
    echo "  just mesh-set-role ROUTER $PORT"
    echo ""
    echo "Or use ROUTER_CLIENT to keep serial access:"
    echo "  just mesh-set-role ROUTER_CLIENT $PORT"

# Set device role (WARNING: ROUTER kills USB serial on ESP32-S3 native USB)
mesh-set-role role port="":
    #!/usr/bin/env bash
    set -euo pipefail
    PORT="{{port}}"
    if [ -z "$PORT" ]; then PORT=$(just detect-port); fi

    if [ "{{role}}" = "ROUTER" ]; then
        echo "WARNING: Setting ROUTER role on ESP32-S3 devices (Station G2)"
        echo "will enable light sleep and KILL USB serial access."
        echo ""
        echo "After this, manage via:"
        echo "  - Admin channel from another mesh node"
        echo "  - Bluetooth (if enabled)"
        echo "  - Re-entering bootloader mode (hold BOOT, plug in)"
        echo ""
        echo "Alternative: ROUTER_CLIENT keeps serial access (slightly higher power)"
        echo ""
        read -p "Set role to ROUTER? [y/N] " -r
        if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 1
        fi
    fi

    meshtastic --port "$PORT" --set device.role "{{role}}"
    echo "Role set to {{role}}."

# Backup device config to configs/backups/
configure-backup port="":
    #!/usr/bin/env bash
    set -euo pipefail
    PORT="{{port}}"
    if [ -z "$PORT" ]; then PORT=$(just detect-port); fi
    mkdir -p configs/backups
    BACKUP="configs/backups/backup-$(date +%Y%m%d-%H%M%S).yaml"
    meshtastic --port "$PORT" --export-config > "$BACKUP"
    echo "Config backed up to: $BACKUP"

# Factory reset a device (interactive confirmation)
configure-reset port="":
    #!/usr/bin/env bash
    set -euo pipefail
    PORT="{{port}}"
    if [ -z "$PORT" ]; then PORT=$(just detect-port); fi
    echo "WARNING: This will factory reset the device!"
    read -p "Are you sure? [y/N] " -r
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
    meshtastic --port "$PORT" --factory-reset
    echo "Device factory reset. It will reboot."

# Generate new PSKs for all 3 channels (prints values for KeePassXC storage)
generate-psks:
    #!/usr/bin/env bash
    set -euo pipefail
    P=$(openssl rand -base64 32)
    A=$(openssl rand -base64 32)
    E=$(openssl rand -base64 32)
    echo "=== LA-Mesh PSKs ==="
    echo "Save these to KeePassXC under the LA-Mesh group."
    echo ""
    echo "  export LAMESH_PSK_PRIMARY=\"$P\""
    echo "  export LAMESH_PSK_ADMIN=\"$A\""
    echo "  export LAMESH_PSK_EMERGENCY=\"$E\""
    echo ""
    echo "Copy the export lines above into your shell before running:"
    echo "  just provision <device> [port]"
    echo ""
    echo "Or save to KeePassXC:"
    echo "  Entry: PSK-Primary   / Username: LAMESH_PSK_PRIMARY   / Password: $P"
    echo "  Entry: PSK-Admin     / Username: LAMESH_PSK_ADMIN     / Password: $A"
    echo "  Entry: PSK-Emergency / Username: LAMESH_PSK_EMERGENCY / Password: $E"

# =============================================================================
# Firmware
# =============================================================================

# Download and verify firmware for a device (or all devices)
fetch-firmware device="all" version="" *FLAGS="":
    ./tools/flash/fetch-firmware.sh --device {{device}} {{FLAGS}} \
        $([ -n "{{version}}" ] && echo "--version {{version}}" || true)

# One-command device provisioning: fetch + flash + configure + channels
provision device port="" *FLAGS="":
    #!/usr/bin/env bash
    set -euo pipefail
    PORT="{{port}}"
    if [ -z "$PORT" ]; then PORT=$(just detect-port); fi
    ./tools/flash/provision-device.sh {{device}} "$PORT" {{FLAGS}}

# Flash Meshtastic firmware (manual -- handles erase + 3-partition write)
flash-meshtastic firmware_file port="" *FLAGS="":
    #!/usr/bin/env bash
    set -euo pipefail
    PORT="{{port}}"
    if [ -z "$PORT" ]; then PORT=$(just detect-port); fi
    ./tools/flash/flash-meshtastic.sh {{firmware_file}} "$PORT" {{FLAGS}}

# Flash MeshCore firmware (manual)
flash-meshcore firmware_file port="":
    #!/usr/bin/env bash
    set -euo pipefail
    PORT="{{port}}"
    if [ -z "$PORT" ]; then PORT=$(just detect-port); fi
    ./tools/flash/flash-meshcore.sh {{firmware_file}} "$PORT"

# Erase ESP32 flash completely (chip-level factory reset, device must be in bootloader)
flash-erase port="":
    #!/usr/bin/env bash
    set -euo pipefail
    PORT="{{port}}"
    if [ -z "$PORT" ]; then PORT=$(just detect-port); fi
    ESPTOOL=$(command -v esptool || command -v esptool.py || { echo "esptool not found"; exit 1; })
    echo "Erasing flash on $PORT..."
    echo "Device must be in bootloader mode (Station G2: hold 'loop' button near USB-C while plugging in)"
    $ESPTOOL --chip auto --port "$PORT" erase_flash

# Check connected ESP32 device (must be in bootloader mode for native USB)
flash-info port="":
    #!/usr/bin/env bash
    set -euo pipefail
    PORT="{{port}}"
    if [ -z "$PORT" ]; then PORT=$(just detect-port); fi
    ESPTOOL=$(command -v esptool || command -v esptool.py || { echo "esptool not found"; exit 1; })
    $ESPTOOL --chip auto --port "$PORT" chip_id

# Full Station G2 flash procedure (interactive, step-by-step)
flash-g2 port="/dev/ttyACM0":
    #!/usr/bin/env bash
    set -euo pipefail
    MANIFEST="firmware/manifest.json"
    CACHE_DIR="${FIRMWARE_CACHE_DIR:-firmware/.cache}"
    PORT="{{port}}"
    ESPTOOL=$(command -v esptool || command -v esptool.py || { echo "esptool not found"; exit 1; })

    VERSION_FULL=$(jq -r '.meshtastic.version_full' "$MANIFEST")
    FW="$CACHE_DIR/firmware-station-g2-${VERSION_FULL}.bin"
    BLEOTA="$CACHE_DIR/bleota-s3.bin"
    LITTLEFS="$CACHE_DIR/littlefs-station-g2-${VERSION_FULL}.bin"

    echo "Station G2 Flash Procedure"
    echo "=========================="
    echo "Firmware:  v${VERSION_FULL}"
    echo "Port:      $PORT"
    echo ""

    # Check files exist
    MISSING=0
    for f in "$FW" "$BLEOTA" "$LITTLEFS"; do
        if [ ! -f "$f" ]; then
            echo "MISSING: $f"
            MISSING=1
        fi
    done
    if [ "$MISSING" -eq 1 ]; then
        echo ""
        echo "Run 'just fetch-firmware --device station-g2' first."
        exit 1
    fi

    echo "Files ready:"
    echo "  Firmware: $(du -h "$FW" | cut -f1)  $FW"
    echo "  BLE OTA:  $(du -h "$BLEOTA" | cut -f1)  $BLEOTA"
    echo "  LittleFS: $(du -h "$LITTLEFS" | cut -f1)  $LITTLEFS"
    echo ""
    echo "IMPORTANT: Device must be in bootloader mode!"
    echo "  1. Unplug USB"
    echo "  2. Hold the 'loop' button (nearest USB-C port)"
    echo "  3. Plug in USB while holding button"
    echo "  4. Hold for 2 more seconds, then release"
    echo ""
    read -p "Device in bootloader mode? [y/N] " -r
    if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi

    echo ""
    echo "[1/4] Erasing flash..."
    $ESPTOOL --chip esp32s3 --port "$PORT" --baud 921600 erase_flash

    echo ""
    echo "[2/4] Writing firmware at 0x0..."
    $ESPTOOL --chip esp32s3 --port "$PORT" --baud 921600 --before no_reset \
        write_flash 0x0 "$FW"

    echo ""
    echo "[3/4] Writing BLE OTA at 0x650000..."
    $ESPTOOL --chip esp32s3 --port "$PORT" --baud 921600 --before no_reset \
        write_flash 0x650000 "$BLEOTA"

    echo ""
    echo "[4/4] Writing LittleFS at 0xc90000..."
    $ESPTOOL --chip esp32s3 --port "$PORT" --baud 921600 --before no_reset \
        write_flash 0xc90000 "$LITTLEFS"

    echo ""
    echo "Flash complete! Unplug and replug the device (without holding any buttons)."
    echo ""
    echo "After reboot (~15s), verify with:"
    echo "  just mesh-info $PORT"
    echo ""
    echo "Then configure (one command does LoRa + channels + owner):"
    echo "  just configure-g2 'LA-Mesh RTR-01' 'R01' $PORT"
    echo ""
    echo "Finally, set ROUTER role (kills USB serial):"
    echo "  just mesh-set-role ROUTER $PORT"

# Regenerate the Maine state silhouette XBM logo
generate-logo:
    python3 tools/assets/generate-maine-xbm.py

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
