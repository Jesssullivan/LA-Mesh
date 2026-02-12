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

# Flash Meshtastic firmware
flash-meshtastic firmware_file port="/dev/ttyUSB0":
    ./tools/flash/flash-meshtastic.sh {{firmware_file}} {{port}}

# Flash MeshCore firmware
flash-meshcore firmware_file port="/dev/ttyUSB0":
    ./tools/flash/flash-meshcore.sh {{firmware_file}} {{port}}

# Erase ESP32 flash (chip-level factory reset)
flash-erase port="/dev/ttyUSB0":
    esptool.py --chip auto --port {{port}} erase_flash

# Check connected ESP32 device
flash-info port="/dev/ttyUSB0":
    esptool.py --chip auto --port {{port}} chip_id

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
