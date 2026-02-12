#!/usr/bin/env bash
# LA-Mesh Range Test Tool
# Sends test messages at intervals and logs responses for range analysis.
#
# Usage:
#   ./tools/test/range-test.sh [--count 10] [--interval 30] [--port /dev/ttyUSB0]
#
# Prerequisites: meshtastic CLI (provided by Nix devShell)
#
# Run this on the TRANSMITTER device. The receiver should be running
# mqtt-to-csv.py or manually logging received messages.

set -euo pipefail

COUNT=10
INTERVAL=30
PORT="/dev/ttyUSB0"
OUTPUT_DIR="hardware/test-results"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="${OUTPUT_DIR}/range-test-${TIMESTAMP}.csv"

usage() {
    echo "LA-Mesh Range Test Tool"
    echo "======================="
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --count N       Number of test messages (default: 10)"
    echo "  --interval N    Seconds between messages (default: 30)"
    echo "  --port PORT     Serial port (default: /dev/ttyUSB0)"
    echo "  --output DIR    Output directory (default: hardware/test-results)"
    echo "  -h, --help      Show this help"
    echo ""
    echo "Before running:"
    echo "  1. Place transmitter at test location"
    echo "  2. Note GPS coordinates and elevation"
    echo "  3. Start receiver logging (mqtt-to-csv.py or manual)"
    echo "  4. Run this script on transmitter"
    echo ""
    echo "After test:"
    echo "  1. Collect receiver logs"
    echo "  2. Match sent vs received messages"
    echo "  3. Calculate delivery rate and SNR statistics"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --count) COUNT="$2"; shift 2 ;;
        --interval) INTERVAL="$2"; shift 2 ;;
        --port) PORT="$2"; shift 2 ;;
        --output) OUTPUT_DIR="$2"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1"; usage; exit 1 ;;
    esac
done

mkdir -p "$OUTPUT_DIR"

echo "LA-Mesh Range Test"
echo "==================="
echo "Messages: $COUNT"
echo "Interval: ${INTERVAL}s"
echo "Port:     $PORT"
echo "Output:   $OUTPUT_FILE"
echo ""

# Get device info
echo "Getting device info..."
DEVICE_INFO=$(meshtastic --port "$PORT" --info 2>&1 | head -20) || {
    echo "ERROR: Cannot communicate with device on $PORT"
    exit 1
}
echo "$DEVICE_INFO" | head -5
echo ""

# Write CSV header
echo "msg_num,timestamp_utc,test_id,message" > "$OUTPUT_FILE"

TEST_ID="RT-${TIMESTAMP}"
echo "Test ID: $TEST_ID"
echo "Starting test in 5 seconds..."
sleep 5

for i in $(seq 1 "$COUNT"); do
    TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    MSG="RANGE_TEST ${TEST_ID} ${i}/${COUNT} ${TS}"

    echo "[${i}/${COUNT}] Sending: ${MSG}"
    meshtastic --port "$PORT" --sendtext "$MSG" 2>/dev/null || {
        echo "  WARNING: Send failed for message $i"
    }

    echo "${i},${TS},${TEST_ID},${MSG}" >> "$OUTPUT_FILE"

    if [ "$i" -lt "$COUNT" ]; then
        echo "  Waiting ${INTERVAL}s..."
        sleep "$INTERVAL"
    fi
done

echo ""
echo "Test complete! $COUNT messages sent."
echo "Results: $OUTPUT_FILE"
echo ""
echo "Next steps:"
echo "  1. Collect receiver logs"
echo "  2. Match messages by TEST_ID: $TEST_ID"
echo "  3. Calculate: delivered/sent = delivery rate"
echo "  4. Record SNR/RSSI from receiver node list"
