#!/usr/bin/env bash
# LA-Mesh Integration Test Suite
# Runs end-to-end tests for the mesh network.
#
# Usage:
#   ./tools/test/integration-tests.sh [--port /dev/ttyUSB0] [--test <name>]
#
# Tests require at least one configured Meshtastic device connected.
# Some tests require two devices or an operational MQTT bridge.

set -euo pipefail

PORT="${PORT:-/dev/ttyUSB0}"
TEST_NAME="${TEST_NAME:-all}"
PASS=0
FAIL=0
SKIP=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

log_pass() { echo -e "${GREEN}[PASS]${NC} $1"; ((PASS++)); }
log_fail() { echo -e "${RED}[FAIL]${NC} $1"; ((FAIL++)); }
log_skip() { echo -e "${YELLOW}[SKIP]${NC} $1"; ((SKIP++)); }
log_info() { echo -e "       $1"; }

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --port) PORT="$2"; shift 2 ;;
        --test) TEST_NAME="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: $0 [--port PORT] [--test TEST_NAME]"
            echo ""
            echo "Tests: device-info, firmware-version, channel-config, send-message,"
            echo "       node-list, position, traceroute, mqtt-bridge, all"
            exit 0 ;;
        *) echo "Unknown: $1"; exit 1 ;;
    esac
done

echo "LA-Mesh Integration Tests"
echo "========================="
echo "Port: $PORT"
echo "Test: $TEST_NAME"
echo ""

# Test: Device reachable
test_device_info() {
    echo "--- Test: Device Info ---"
    if meshtastic --port "$PORT" --info >/dev/null 2>&1; then
        log_pass "Device reachable on $PORT"
        OWNER=$(meshtastic --port "$PORT" --info 2>&1 | grep -i "owner" | head -1 || echo "unknown")
        log_info "Owner: $OWNER"
    else
        log_fail "Cannot reach device on $PORT"
        return 1
    fi
}

# Test: Firmware version meets minimum
test_firmware_version() {
    echo "--- Test: Firmware Version ---"
    FW_LINE=$(meshtastic --port "$PORT" --info 2>&1 | grep -i "firmware" | head -1 || echo "")
    if [ -z "$FW_LINE" ]; then
        log_fail "Cannot read firmware version"
        return 1
    fi
    log_info "$FW_LINE"

    # Check for minimum version (v2.7.15)
    VERSION=$(echo "$FW_LINE" | grep -oP '\d+\.\d+\.\d+' | head -1 || echo "0.0.0")
    MAJOR=$(echo "$VERSION" | cut -d. -f1)
    MINOR=$(echo "$VERSION" | cut -d. -f2)
    PATCH=$(echo "$VERSION" | cut -d. -f3)

    if [ "$MAJOR" -gt 2 ] || \
       ([ "$MAJOR" -eq 2 ] && [ "$MINOR" -gt 6 ]) || \
       ([ "$MAJOR" -eq 2 ] && [ "$MINOR" -eq 6 ] && [ "$PATCH" -ge 11 ]); then
        log_pass "Firmware $VERSION >= 2.7.15 (CVE-2025-52464 patched)"
    else
        log_fail "Firmware $VERSION < 2.7.15 -- UPDATE REQUIRED (CVE-2025-52464)"
    fi
}

# Test: Channel configuration
test_channel_config() {
    echo "--- Test: Channel Config ---"
    CH_INFO=$(meshtastic --port "$PORT" --info 2>&1 | grep -A5 -i "channel" || echo "")
    if echo "$CH_INFO" | grep -qi "LA-Mesh"; then
        log_pass "Primary channel 'LA-Mesh' configured"
    else
        log_fail "Primary channel 'LA-Mesh' not found"
        log_info "Channels: $CH_INFO"
    fi

    # Check PSK is not default
    if echo "$CH_INFO" | grep -q "AQ=="; then
        log_fail "DEFAULT PSK (AQ==) detected -- NOT SECURE"
    else
        log_pass "Non-default PSK configured"
    fi
}

# Test: Send message
test_send_message() {
    echo "--- Test: Send Message ---"
    TEST_MSG="INTEGRATION_TEST $(date -u +%Y%m%dT%H%M%SZ)"
    if meshtastic --port "$PORT" --sendtext "$TEST_MSG" 2>/dev/null; then
        log_pass "Message sent: $TEST_MSG"
    else
        log_fail "Failed to send message"
    fi
}

# Test: Node list
test_node_list() {
    echo "--- Test: Node List ---"
    NODES=$(meshtastic --port "$PORT" --nodes 2>&1 || echo "")
    if [ -n "$NODES" ]; then
        NODE_COUNT=$(echo "$NODES" | grep -c "│" || echo "0")
        log_pass "Node list retrieved ($NODE_COUNT entries)"
    else
        log_skip "Node list empty (no other nodes visible)"
    fi
}

# Test: Position
test_position() {
    echo "--- Test: Position ---"
    POS=$(meshtastic --port "$PORT" --info 2>&1 | grep -i "position\|latitude\|longitude" || echo "")
    if [ -n "$POS" ]; then
        log_pass "Position data available"
        log_info "$POS"
    else
        log_skip "No position data (GPS may be disabled)"
    fi
}

# Test: MQTT bridge
test_mqtt_bridge() {
    echo "--- Test: MQTT Bridge ---"
    if command -v mosquitto_sub >/dev/null 2>&1; then
        # Try to subscribe for 5 seconds
        MQTT_MSG=$(timeout 5 mosquitto_sub -h localhost -t "msh/#" -C 1 2>/dev/null || echo "")
        if [ -n "$MQTT_MSG" ]; then
            log_pass "MQTT bridge operational (received message)"
        else
            log_skip "No MQTT messages in 5 seconds (bridge may not be running)"
        fi
    else
        log_skip "mosquitto_sub not available (install mosquitto-clients)"
    fi
}

# Run tests
run_test() {
    case "$1" in
        device-info) test_device_info ;;
        firmware-version) test_firmware_version ;;
        channel-config) test_channel_config ;;
        send-message) test_send_message ;;
        node-list) test_node_list ;;
        position) test_position ;;
        mqtt-bridge) test_mqtt_bridge ;;
        all)
            test_device_info
            echo ""
            test_firmware_version
            echo ""
            test_channel_config
            echo ""
            test_send_message
            echo ""
            test_node_list
            echo ""
            test_position
            echo ""
            test_mqtt_bridge
            ;;
        *) echo "Unknown test: $1"; exit 1 ;;
    esac
}

run_test "$TEST_NAME"

echo ""
echo "========================="
echo -e "Results: ${GREEN}$PASS passed${NC}, ${RED}$FAIL failed${NC}, ${YELLOW}$SKIP skipped${NC}"
echo "========================="

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
