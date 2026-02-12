# Bench Testing Protocol

**Purpose**: Establish baseline RF performance for each device type before field deployment
**When**: After flashing firmware and applying profiles, before outdoor deployment

---

## Equipment Needed

- 2+ configured Meshtastic devices
- USB cables for serial connection
- Laptop with meshtastic CLI
- Notebook for recording observations
- Tape measure or known distances
- Stopwatch / timer

---

## Test 1: Basic Communication (Indoor)

**Setup**: Two devices, same room, <5m apart

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Power on both devices | Both show on each other's node list within 60s |
| 2 | Send text from Device A | Message appears on Device B within 5s |
| 3 | Send text from Device B | Message appears on Device A within 5s |
| 4 | Note RSSI and SNR on both devices | RSSI > -50 dBm, SNR > 10 dB |

**Record**: Device IDs, firmware versions, RSSI, SNR, time to first message.

---

## Test 2: Range Baseline (Indoor)

**Setup**: One device stationary, one device moved through building

| Distance | Location | RSSI | SNR | Delivered? |
|----------|----------|------|-----|-----------|
| 0-5m | Same room | | | |
| 5-15m | Adjacent room | | | |
| 15-30m | Through 1 wall | | | |
| 30-50m | Through 2 walls | | | |
| 50-100m | Different floor | | | |

Send 3 messages at each location. Record delivery rate (N/3).

---

## Test 3: Range Baseline (Outdoor)

**Setup**: One device at fixed point, one device walked away in open area

| Distance | RSSI | SNR | Delivered? | Terrain Notes |
|----------|------|-----|-----------|---------------|
| 50m | | | | |
| 100m | | | | |
| 200m | | | | |
| 500m | | | | |
| 1000m | | | | |
| 2000m | | | | |

Use GPS or known landmarks for distance measurement.

---

## Test 4: Multi-Hop Routing

**Setup**: 3 devices in a line. Devices A and C cannot directly reach each other.

```
Device A ──(within range)──> Device B ──(within range)──> Device C
       <──────── beyond direct range ─────────>
```

| Step | Action | Expected Result |
|------|--------|-----------------|
| 1 | Send message from A | Appears on B (direct) and C (1 hop via B) |
| 2 | Check hop count on C | Should show 2 hops |
| 3 | Run traceroute from A to C | Shows A → B → C path |
| 4 | Remove/power off B | Message from A should NOT reach C |
| 5 | Power on B again | Messages resume flowing A → B → C |

---

## Test 5: Antenna Comparison

**Setup**: Same two devices, same distance (100m recommended). Swap antennas on one device.

| Antenna | RSSI | SNR | Notes |
|---------|------|-----|-------|
| Stock whip (~2 dBi) | | | |
| Upgraded omni (6 dBi) | | | |
| Difference | | | Expect ~4 dB improvement |

---

## Test 6: Battery Life Baseline

**Setup**: Fully charge device, configure for intended role, leave running.

| Device | Role | GPS | BLE | Screen | Start Time | 50% Time | 20% Time | Dead Time |
|--------|------|-----|-----|--------|------------|----------|----------|-----------|
| | | | | | | | | |

Run until battery dies or 48h, whichever comes first.

---

## Recording Results

Save all test data to `hardware/test-results/`:

```bash
# Use the range test tool for automated testing
./tools/test/range-test.sh --count 5 --interval 60

# Manual recording
echo "device,distance,rssi,snr,delivered,notes" > hardware/test-results/baseline-$(date +%Y%m%d).csv
```

---

## Interpreting Results

### RSSI (Received Signal Strength Indicator)

| RSSI | Quality |
|------|---------|
| > -80 dBm | Excellent |
| -80 to -100 dBm | Good |
| -100 to -120 dBm | Marginal |
| -120 to -137 dBm | Weak (near sensitivity limit for SF11) |
| < -137 dBm | Below sensitivity -- no reception |

### SNR (Signal-to-Noise Ratio)

| SNR | Quality |
|-----|---------|
| > 10 dB | Excellent |
| 5 to 10 dB | Good |
| 0 to 5 dB | Marginal |
| -5 to 0 dB | Poor but may work with high SF |
| < -5 dB | Likely no decode |
