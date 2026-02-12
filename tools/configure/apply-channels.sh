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
# Set them in your shell session or .env file (gitignored).

set -euo pipefail

PORT="${1:-/dev/ttyUSB0}"

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
    echo "Or source from your .env file:"
    echo "  source .env"
    exit 1
fi

echo "Configuring Channel 0: LA-Mesh (Primary)..."
meshtastic --port "$PORT" --ch-set name "LA-Mesh" --ch-index 0
meshtastic --port "$PORT" --ch-set psk "$LAMESH_PSK_PRIMARY" --ch-index 0
meshtastic --port "$PORT" --ch-set uplink_enabled false --ch-index 0
meshtastic --port "$PORT" --ch-set downlink_enabled false --ch-index 0

if [ -n "${LAMESH_PSK_ADMIN:-}" ]; then
    echo "Configuring Channel 1: LA-Admin..."
    meshtastic --port "$PORT" --ch-set name "LA-Admin" --ch-index 1
    meshtastic --port "$PORT" --ch-set psk "$LAMESH_PSK_ADMIN" --ch-index 1
    meshtastic --port "$PORT" --ch-set uplink_enabled false --ch-index 1
    meshtastic --port "$PORT" --ch-set downlink_enabled false --ch-index 1
else
    echo "LAMESH_PSK_ADMIN not set, skipping admin channel"
fi

if [ -n "${LAMESH_PSK_EMERGENCY:-}" ]; then
    echo "Configuring Channel 2: LA-Emergency..."
    meshtastic --port "$PORT" --ch-set name "LA-Emergency" --ch-index 2
    meshtastic --port "$PORT" --ch-set psk "$LAMESH_PSK_EMERGENCY" --ch-index 2
    meshtastic --port "$PORT" --ch-set uplink_enabled false --ch-index 2
    meshtastic --port "$PORT" --ch-set downlink_enabled false --ch-index 2
else
    echo "LAMESH_PSK_EMERGENCY not set, skipping emergency channel"
fi

echo ""
echo "Channel configuration complete."
echo ""
echo "Verify with:"
echo "  meshtastic --port $PORT --info"
