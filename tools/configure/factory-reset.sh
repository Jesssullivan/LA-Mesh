#!/usr/bin/env bash
# LA-Mesh: Factory reset a Meshtastic device
# Usage: ./tools/configure/factory-reset.sh [port]
#
# WARNING: This erases ALL configuration. Back up first!

set -euo pipefail

PORT="${1:-/dev/ttyUSB0}"

echo "LA-Mesh Factory Reset"
echo "====================="
echo "Port: $PORT"
echo ""
echo "WARNING: This will erase ALL device configuration!"
echo "         Back up first: ./tools/configure/backup-config.sh $PORT"
echo ""
read -p "Type 'RESET' to confirm: " CONFIRM

if [ "$CONFIRM" != "RESET" ]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "Performing factory reset..."
meshtastic --port "$PORT" --factory-reset || {
    echo "ERROR: Factory reset failed"
    exit 1
}

echo ""
echo "Factory reset complete. Device will reboot."
echo ""
echo "Next steps:"
echo "  1. Wait for device to reboot (~10 seconds)"
echo "  2. Apply a profile: ./tools/configure/apply-profile.sh <profile> $PORT"
echo "  3. Apply channels: ./tools/configure/apply-channels.sh $PORT"
