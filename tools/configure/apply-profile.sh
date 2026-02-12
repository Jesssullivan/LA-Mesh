#!/usr/bin/env bash
# LA-Mesh: Apply a device configuration profile
# Usage: ./tools/configure/apply-profile.sh <profile> [port]
#
# Profiles: station-g2-router, tdeck-plus-client, tdeck-pro-eink-client,
#           meshadv-mini-gateway, mqtt-gateway

set -euo pipefail

PROFILE="${1:-}"
PORT="${2:-/dev/ttyUSB0}"
PROFILES_DIR="configs/profiles"

if [ -z "$PROFILE" ]; then
    echo "LA-Mesh Profile Applicator"
    echo "=========================="
    echo ""
    echo "Usage: $0 <profile-name> [port]"
    echo ""
    echo "Available profiles:"
    for f in "$PROFILES_DIR"/*.yaml; do
        name=$(basename "$f" .yaml)
        echo "  $name"
    done
    echo ""
    echo "Example:"
    echo "  $0 station-g2-router /dev/ttyUSB0"
    exit 1
fi

PROFILE_FILE="${PROFILES_DIR}/${PROFILE}.yaml"
if [ ! -f "$PROFILE_FILE" ]; then
    echo "ERROR: Profile not found: $PROFILE_FILE"
    echo ""
    echo "Available profiles:"
    for f in "$PROFILES_DIR"/*.yaml; do
        echo "  $(basename "$f" .yaml)"
    done
    exit 1
fi

echo "LA-Mesh Profile Applicator"
echo "=========================="
echo "Profile: $PROFILE"
echo "File:    $PROFILE_FILE"
echo "Port:    $PORT"
echo ""

# Backup current config first
BACKUP_DIR="configs/backups"
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="${BACKUP_DIR}/backup-$(date +%Y%m%d-%H%M%S).yaml"
echo "Backing up current config to $BACKUP_FILE..."
meshtastic --port "$PORT" --export-config > "$BACKUP_FILE" 2>/dev/null || {
    echo "WARNING: Could not backup current config (device may be fresh)"
}

echo "Applying profile: $PROFILE..."
meshtastic --port "$PORT" --configure "$PROFILE_FILE" || {
    echo "ERROR: Failed to apply profile"
    echo ""
    echo "Troubleshooting:"
    echo "  - Is the device connected and powered on?"
    echo "  - Is the port correct? Try: ls /dev/ttyUSB* /dev/ttyACM*"
    echo "  - Is the firmware updated to v2.7.15+?"
    exit 1
}

echo ""
echo "Profile applied. Verifying..."
sleep 2

meshtastic --port "$PORT" --info | head -30

echo ""
echo "Profile '$PROFILE' applied successfully."
echo "Backup saved to: $BACKUP_FILE"
echo ""
echo "Next: Set channel PSK with:"
echo "  meshtastic --port $PORT --ch-set psk <base64-psk> --ch-index 0"
