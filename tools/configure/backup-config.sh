#!/usr/bin/env bash
# LA-Mesh: Backup device configuration
# Usage: ./tools/configure/backup-config.sh [port] [output-dir]

set -euo pipefail

PORT="${1:-/dev/ttyUSB0}"
OUTPUT_DIR="${2:-configs/backups}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

mkdir -p "$OUTPUT_DIR"

echo "Backing up device config from $PORT..."

# Get device info for filename
NODE_INFO=$(meshtastic --port "$PORT" --info 2>&1 | grep -i "owner" | head -1 || echo "unknown")
OWNER=$(echo "$NODE_INFO" | sed 's/.*Owner: //' | sed 's/[^a-zA-Z0-9_-]/_/g' | head -c 20)

OUTPUT_FILE="${OUTPUT_DIR}/${OWNER:-device}-${TIMESTAMP}.yaml"

meshtastic --port "$PORT" --export-config > "$OUTPUT_FILE" || {
    echo "ERROR: Failed to export config"
    exit 1
}

echo "Config saved to: $OUTPUT_FILE"
echo ""
echo "To restore:"
echo "  meshtastic --port $PORT --configure $OUTPUT_FILE"
