#!/usr/bin/env bash
# LA-Mesh: Apply channel configuration to a device
# Usage: ./tools/configure/apply-channels.sh [port]
#
# Reads PSK values from environment variables:
#   LAMESH_PSK_PRIMARY   - Primary channel PSK (base64)
#   LAMESH_PSK_ADMIN     - Admin channel PSK (base64)
#   LAMESH_PSK_EMERGENCY - Emergency channel PSK (base64)
#
# SECURITY: PSK values should NEVER be hardcoded or committed.
# Set them in your shell session from your encrypted keystore.
#
# IMPORTANT: Secondary channels (1, 2) use --ch-add on fresh devices
# because --ch-set on a non-existent channel silently fails.
# Channel names max 11 characters (Meshtastic firmware limit).

set -euo pipefail

PORT="${1:-/dev/ttyUSB0}"
REBOOT_WAIT="${LAMESH_REBOOT_WAIT:-15}"

echo "LA-Mesh Channel Configuration"
echo "=============================="
echo "Port: $PORT"
echo ""

# Check for PSK environment variables
if [ -z "${LAMESH_PSK_PRIMARY:-}" ]; then
    echo "ERROR: LAMESH_PSK_PRIMARY not set"
    echo ""
    echo "Set PSK environment variables before running:"
    echo "  export LAMESH_PSK_PRIMARY=\$(openssl rand -base64 32)"
    echo "  export LAMESH_PSK_ADMIN=\$(openssl rand -base64 32)"
    echo "  export LAMESH_PSK_EMERGENCY=\$(openssl rand -base64 32)"
    echo ""
    echo "Or export from your keystore (e.g. KeePassXC CLI)."
    echo "Or generate fresh PSKs with: just generate-psks"
    exit 1
fi

# Helper: wait for device after reboot-triggering commands
wait_for_device() {
    echo "  Waiting ${REBOOT_WAIT}s for device to stabilize..."
    sleep "$REBOOT_WAIT"
    local retries=0
    while ! meshtastic --port "$PORT" --info &>/dev/null; do
        retries=$((retries + 1))
        if [ "$retries" -ge 4 ]; then
            echo "  WARNING: Device not responding. It may need manual reconnection."
            return 1
        fi
        echo "  Waiting for device... (attempt $retries/4)"
        sleep 5
    done
}

# --- Channel 0: LA-Mesh (Primary) ---
echo "[1/3] Configuring Channel 0: LA-Mesh (Primary)..."
meshtastic --port "$PORT" \
    --ch-index 0 \
    --ch-set name "LA-Mesh" \
    --ch-set psk "base64:${LAMESH_PSK_PRIMARY}"
wait_for_device

# --- Channel 1: LA-Admin (Secondary -- must --ch-add on fresh device) ---
if [ -n "${LAMESH_PSK_ADMIN:-}" ]; then
    echo "[2/3] Adding Channel 1: LA-Admin..."
    meshtastic --port "$PORT" --ch-add "LA-Admin"
    sleep 5
    meshtastic --port "$PORT" \
        --ch-index 1 \
        --ch-set psk "base64:${LAMESH_PSK_ADMIN}"
    wait_for_device
else
    echo "[2/3] LAMESH_PSK_ADMIN not set, skipping admin channel"
fi

# --- Channel 2: LA-Emergcy (11 char limit -- "LA-Emergency" is 12) ---
if [ -n "${LAMESH_PSK_EMERGENCY:-}" ]; then
    echo "[3/3] Adding Channel 2: LA-Emergcy..."
    meshtastic --port "$PORT" --ch-add "LA-Emergcy"
    sleep 5
    meshtastic --port "$PORT" \
        --ch-index 2 \
        --ch-set psk "base64:${LAMESH_PSK_EMERGENCY}"
    wait_for_device
else
    echo "[3/3] LAMESH_PSK_EMERGENCY not set, skipping emergency channel"
fi

echo ""
echo "Channel configuration complete."
echo ""
echo "Verify with:"
echo "  meshtastic --port $PORT --info"
